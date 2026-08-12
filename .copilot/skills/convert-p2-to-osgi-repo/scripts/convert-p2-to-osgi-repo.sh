#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

script_name=${0##*/}
BND_JAR=${BND_JAR:-"$HOME/biz.aQute.bnd.jar"}
dry_run=false
target_arg=
temp_root=
index_stage=
config_stage=
config_backup=
backup_path=
old_index_moved=false
index_installed=false
config_installed=false
mutation_started=false

err() {
    printf '%s: %s\n' "$script_name" "$*" >&2
}

die() {
    err "$*"
    exit 1
}

usage() {
    cat <<'EOF'
Usage: convert-p2-to-osgi-repo.sh [--dry-run] <workspace>/cnf/ext/<name>.bnd

Switch one active Eclipse P2Repository configuration to a local OSGiRepository.
Set BND_JAR to override the default $HOME/biz.aQute.bnd.jar.
EOF
}

rollback() {
    local rollback_status=0

    if [[ "$config_installed" == true && -n "$config_backup" && -f "$config_backup" ]]; then
        if ! cp -- "$config_backup" "$target_path"; then
            rollback_status=1
        fi
    fi

    if [[ "$index_installed" == true ]]; then
        if ! rm -f -- "$index_path"; then
            rollback_status=1
        fi
    fi

    if [[ "$old_index_moved" == true && -n "$backup_path" && -f "$backup_path" ]]; then
        if ! mv -- "$backup_path" "$index_path"; then
            rollback_status=1
        fi
    fi

    return "$rollback_status"
}

cleanup() {
    local status=$?
    trap - EXIT

    if [[ "$mutation_started" == true && "$status" -ne 0 ]]; then
        if rollback; then
            err "mutation failed; original configuration and index restored"
        else
            err "mutation failed; rollback also failed"
            status=2
        fi
    fi

    [[ -z "$index_stage" ]] || rm -f -- "$index_stage"
    [[ -z "$config_stage" ]] || rm -f -- "$config_stage"
    [[ -z "$temp_root" ]] || rm -rf -- "$temp_root"
    exit "$status"
}

trap cleanup EXIT

while (($# > 0)); do
    case "$1" in
        --dry-run)
            dry_run=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            (($# == 1)) || die "exactly one .bnd path required"
            target_arg=$1
            shift
            break
            ;;
        -*)
            die "unknown option: $1"
            ;;
        *)
            [[ -z "$target_arg" ]] || die "exactly one .bnd path required"
            target_arg=$1
            ;;
    esac
    shift
done

[[ -n "$target_arg" ]] || {
    usage >&2
    exit 2
}

target_arg=${target_arg//\\//}
if [[ "$target_arg" =~ ^[A-Za-z]:/ ]] && command -v cygpath >/dev/null 2>&1; then
    target_arg=$(cygpath -u "$target_arg")
fi

if [[ "$target_arg" = /* ]]; then
    target_path=$target_arg
else
    target_path=$PWD/$target_arg
fi
target_path=$(cd -- "$(dirname -- "$target_path")" && printf '%s/%s' "$PWD" "$(basename -- "$target_path")")

[[ -f "$target_path" ]] || die "target file not found: $target_path"
[[ "$target_path" == *.bnd ]] || die "target must end in .bnd: $target_path"

config_dir=$(dirname -- "$target_path")
cnf_dir=$(dirname -- "$config_dir")
workspace_dir=$(dirname -- "$cnf_dir")
[[ "$(basename -- "$config_dir")" == ext ]] || die "target must be in cnf/ext: $target_path"
[[ "$(basename -- "$cnf_dir")" == cnf ]] || die "target must be in cnf/ext: $target_path"
[[ -d "$workspace_dir/cnf" ]] || die "workspace directory not found: $workspace_dir/cnf"

mapfile -t workspace_p2_files < <(grep -RIl --include='*.bnd' -E '^[[:space:]]*-plugin\.p2\.' "$workspace_dir/cnf/ext" 2>/dev/null || true)
if ((${#workspace_p2_files[@]} > 0)); then
    if ((${#workspace_p2_files[@]} != 1)) || [[ "${workspace_p2_files[0]}" != "$target_path" ]]; then
        die "workspace must contain exactly one active P2Repository configuration: $workspace_dir/cnf/ext"
    fi
fi

target_basename=$(basename -- "$target_path")
stem=${target_basename%.bnd}
[[ "$stem" =~ ^[A-Za-z0-9._-]+$ ]] || die "unsupported .bnd basename: $stem"
index_path=$config_dir/${stem}_index.xml.gz
relative_config=cnf/ext/$target_basename

if [[ "$dry_run" == false ]]; then
    [[ -f "$BND_JAR" ]] || die "bnd JAR not found: $BND_JAR"
    bnd_version=$(java -jar "$BND_JAR" version 2>&1) || die "cannot run bnd CLI: $bnd_version"
    printf 'bnd: %s\n' "$bnd_version"
fi

mapfile -t lines < "$target_path"
line_count=${#lines[@]}
has_crlf=false
if grep -q $'\r$' "$target_path"; then
    has_crlf=true
fi
for i in "${!lines[@]}"; do
    lines[i]=${lines[i]%$'\r'}
done

block_end() {
    local start=$1
    local end=$start
    local next

    while ((end + 1 < line_count)); do
        next=${lines[end + 1]}
        [[ -n "$next" && "$next" =~ ^[[:space:]]+ ]] || break
        end=$((end + 1))
    done
    printf '%s\n' "$end"
}

commented_block_end() {
    local start=$1
    local end=$start
    local next

    while ((end + 1 < line_count)); do
        next=${lines[end + 1]}
        [[ "$next" =~ ^[[:space:]]*#[[:space:]]+ ]] || break
        end=$((end + 1))
    done
    printf '%s\n' "$end"
}

append_line() {
    output_lines+=("$1")
}

write_lines() {
    local path=$1
    if [[ "$has_crlf" == true ]]; then
        printf '%s\r\n' "${output_lines[@]}" > "$path"
    else
        printf '%s\n' "${output_lines[@]}" > "$path"
    fi
}

p2_starts=()
p2_suffixes=()
osgi_starts=()
osgi_suffixes=()
marker_starts=()

for i in "${!lines[@]}"; do
    line=${lines[i]}
    if [[ "$line" =~ ^[[:space:]]*-plugin\.p2\.([^:[:space:]]+)[[:space:]]*: ]]; then
        p2_starts+=("$i")
        p2_suffixes+=("${BASH_REMATCH[1]}")
    fi
    if [[ "$line" =~ ^[[:space:]]*-plugin\.osgi\.([^:[:space:]]+)[[:space:]]*: ]]; then
        osgi_starts+=("$i")
        osgi_suffixes+=("${BASH_REMATCH[1]}")
    fi
    if [[ "$line" == '# Generated by convert-p2-to-osgi-repo.' ]]; then
        marker_starts+=("$i")
    fi
done

if ((${#p2_starts[@]} > 1)); then
    die "more than one active P2Repository block found"
fi
if ((${#marker_starts[@]} > 1)); then
    die "more than one generated conversion marker found"
fi

original_lines=()
generation_lines=("${lines[@]}")
replacement_start=-1
replacement_end=-1
plugin_suffix=
p2_start=-1
p2_end=-1
marker_start=-1

if ((${#p2_starts[@]} == 1)); then
    p2_start=${p2_starts[0]}
    p2_end=$(block_end "$p2_start")
    plugin_suffix=${p2_suffixes[0]}

    for ((i = p2_start; i <= p2_end; i++)); do
        original_lines+=("${lines[i]}")
    done

    for j in "${!osgi_starts[@]}"; do
        if [[ "${osgi_suffixes[j]}" == "$plugin_suffix" ]]; then
            die "active OSGiRepository already exists beside active P2Repository: $plugin_suffix"
        fi
    done
    replacement_start=$p2_start
    replacement_end=$p2_end
else
    ((${#marker_starts[@]} == 1)) || die "no active P2Repository block or recognized conversion marker found"
    marker_start=${marker_starts[0]}
    commented_p2_start=-1
    commented_p2_end=-1

    for ((i = marker_start + 1; i < line_count; i++)); do
        if [[ "${lines[i]}" =~ ^[[:space:]]*#[[:space:]]*-plugin\.p2\.([^:[:space:]]+)[[:space:]]*: ]]; then
            [[ "$commented_p2_start" == -1 ]] || die "more than one retained P2Repository block found"
            commented_p2_start=$i
            plugin_suffix=${BASH_REMATCH[1]}
        fi
    done
    [[ "$commented_p2_start" != -1 ]] || die "conversion marker has no retained P2Repository block"
    commented_p2_end=$(commented_block_end "$commented_p2_start")

    matching_osgi=()
    for j in "${!osgi_starts[@]}"; do
        if [[ "${osgi_suffixes[j]}" == "$plugin_suffix" ]]; then
            matching_osgi+=("${osgi_starts[j]}")
        fi
    done
    ((${#matching_osgi[@]} == 1)) || die "conversion marker does not have exactly one matching OSGiRepository block"
    osgi_start=${matching_osgi[0]}
    osgi_end=$(block_end "$osgi_start")

    for ((i = commented_p2_start; i <= commented_p2_end; i++)); do
        commented_line=${lines[i]}
        original_lines+=("${commented_line#\# }")
    done
    replacement_start=$marker_start
    replacement_end=$osgi_end

    generation_lines=()
    for ((i = 0; i < line_count; i++)); do
        if ((i == marker_start)); then
            generation_lines+=("${original_lines[@]}")
            i=$osgi_end
        else
            generation_lines+=("${lines[i]}")
        fi
    done
fi

original_block_text=$(printf '%s\n' "${original_lines[@]}")
name_pattern="name[[:space:]]*=[[:space:]]*'([^']*)'"
p2_name=
while IFS= read -r line; do
    if [[ "$line" =~ $name_pattern ]]; then
        p2_name=${BASH_REMATCH[1]}
        break
    fi
done <<< "$original_block_text"
[[ -n "$p2_name" ]] || die "P2Repository block has no single-line name property"
[[ "$p2_name" != *"'"* ]] || die "P2 repository name contains unsupported single quote"

if ! grep -Eq '(^|[[:space:]])url[[:space:]]*=' <<< "$original_block_text"; then
    die "P2Repository block has no url property"
fi
if grep -Eq '(^|[[:space:]])location[[:space:]]*=' <<< "$original_block_text"; then
    die "P2Repository location is explicit; helper requires default workspace P2 cache"
fi

generated_name=${p2_name/P2 /}
version_pattern='\$\{eclipse\.[A-Za-z0-9_.-]*version\.[^}]+\}'
version_macro=
while IFS= read -r line; do
    if [[ "$line" =~ $version_pattern ]]; then
        version_macro=${BASH_REMATCH[0]}
        break
    fi
done <<< "$original_block_text"
cache_suffix=${version_macro:-$stem}

generated_lines=(
    "-plugin.osgi.${plugin_suffix}: \\"
    "    aQute.bnd.repository.osgi.OSGiRepository; \\"
    "        name      = '${generated_name}'; \\"
    "        locations = '\${fileuri;\${.}/${stem}_index.xml.gz}'; \\"
    "        cache     = '\${build}/cache/ecl_${cache_suffix}'"
)

output_lines=()
for ((i = 0; i < line_count; i++)); do
    if ((i == replacement_start)); then
        append_line '# Generated by convert-p2-to-osgi-repo.'
        append_line '# Original P2Repository configuration retained for index regeneration.'
        for original_line in "${original_lines[@]}"; do
            append_line "# ${original_line}"
        done
        append_line ''
        output_lines+=("${generated_lines[@]}")
        i=$replacement_end
    else
        append_line "${lines[i]}"
    fi
done
final_lines=("${output_lines[@]}")

printf 'target: %s\n' "$target_path"
printf 'index: %s\n' "$index_path"
printf 'plugin: -plugin.osgi.%s\n' "$plugin_suffix"
if [[ -f "$index_path" ]]; then
    timestamp=$(date -u +%Y%m%d-%H%M%S)
    backup_path=$config_dir/${stem}_${timestamp}_index.xml.gz
    backup_number=1
    while [[ -e "$backup_path" || -L "$backup_path" ]]; do
        backup_path=$config_dir/${stem}_${timestamp}-${backup_number}_index.xml.gz
        backup_number=$((backup_number + 1))
    done
fi
[[ -z "$backup_path" ]] || printf 'backup: %s\n' "$backup_path"

if [[ "$dry_run" == true ]]; then
    printf '%s\n' 'generated configuration block:'
    printf '%s\n' "${generated_lines[@]}"
    exit 0
fi

temp_root=$(mktemp -d "${TMPDIR:-/tmp}/switch-eclipse-p2.XXXXXX")
generation_workspace=$temp_root/generation
validation_workspace=$temp_root/validation
mkdir -p "$generation_workspace" "$validation_workspace"
cp -a -- "$workspace_dir"/. "$generation_workspace"/
cp -a -- "$workspace_dir"/. "$validation_workspace"/

generation_config=$generation_workspace/$relative_config
validation_config=$validation_workspace/$relative_config
if ((${#p2_starts[@]} == 1)); then
    output_for_generation=("${lines[@]}")
else
    output_for_generation=("${generation_lines[@]}")
fi
output_lines=("${output_for_generation[@]}")
write_lines "$generation_config"

if [[ -d "$generation_workspace/cnf/cache" ]]; then
    find "$generation_workspace/cnf/cache" -type f -name index.xml.gz -delete
    find "$generation_workspace/cnf/cache" -depth -type d -name 'p2-*' -empty -delete
fi

generation_output=$temp_root/generation.out
if ! java -jar "$BND_JAR" repo -w "$generation_workspace" list > "$generation_output" 2>&1; then
    sed -n '1,80p' "$generation_output" >&2
    die "bnd could not generate P2 index"
fi

mapfile -t generated_indexes < <(find "$generation_workspace/cnf/cache" -type f -path '*/p2-*/index.xml.gz' -print)
((${#generated_indexes[@]} == 1)) || die "expected one generated P2 index, found ${#generated_indexes[@]}"
generated_index=${generated_indexes[0]}
gzip -t "$generated_index" || die "generated P2 index is not valid gzip: $generated_index"

final_config=$temp_root/final.bnd
output_lines=("${final_lines[@]}")
write_lines "$final_config"
cp -- "$final_config" "$validation_config"
cp -- "$generated_index" "$validation_workspace/cnf/ext/${stem}_index.xml.gz"

validation_output=$temp_root/validation.out
if ! java -jar "$BND_JAR" repo -w "$validation_workspace" list > "$validation_output" 2>&1; then
    sed -n '1,80p' "$validation_output" >&2
    die "generated OSGiRepository configuration failed validation"
fi

config_backup=$temp_root/original.bnd
cp -- "$target_path" "$config_backup"
mutation_started=true

if [[ -n "$backup_path" ]]; then
    mv -- "$index_path" "$backup_path"
    old_index_moved=true
fi

index_stage=$(mktemp "$config_dir/.${stem}_index.xml.gz.tmp.XXXXXX")
cp -- "$generated_index" "$index_stage"
mv -- "$index_stage" "$index_path"
index_stage=
index_installed=true

config_stage=$(mktemp "$config_dir/.${stem}.bnd.tmp.XXXXXX")
cp -- "$final_config" "$config_stage"
mv -- "$config_stage" "$target_path"
config_stage=
config_installed=true

mapfile -t pre_final_cache_dirs < <(find "$workspace_dir/cnf/cache" -maxdepth 1 -type d -name 'ecl_*' 2>/dev/null || true)

final_output=$temp_root/final.out
if ! java -jar "$BND_JAR" repo -w "$workspace_dir" list > "$final_output" 2>&1; then
    sed -n '1,80p' "$final_output" >&2
    die "final workspace validation failed"
fi

mapfile -t post_final_cache_dirs < <(find "$workspace_dir/cnf/cache" -maxdepth 1 -type d -name 'ecl_*' 2>/dev/null || true)
for cache_dir in "${post_final_cache_dirs[@]}"; do
    is_new_cache_dir=true
    for pre_cache_dir in "${pre_final_cache_dirs[@]}"; do
        [[ "$cache_dir" != "$pre_cache_dir" ]] || { is_new_cache_dir=false; break; }
    done
    [[ "$is_new_cache_dir" == false ]] || rm -rf -- "$cache_dir"
done

printf 'switched: %s\n' "$target_path"
printf 'generated: %s\n' "$index_path"
[[ -z "$backup_path" ]] || printf 'backup: %s\n' "$backup_path"