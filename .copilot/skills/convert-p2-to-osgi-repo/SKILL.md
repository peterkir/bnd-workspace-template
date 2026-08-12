---
name: convert-p2-to-osgi-repo
description: >
  Switch one Eclipse P2Repository definition in a bnd workspace to a local
  OSGiRepository backed by a freshly generated OSGi repository index. Use when
  converting Eclipse platform or SimRel repository configuration, refreshing
  a checked-in P2 index, or asking for the bnd CLI workflow for this change.
---

# Switch Eclipse P2 Repository

Use this skill for one `.bnd` file at a time. The target must be under
`<workspace>/cnf/ext/` and must contain one active
`-plugin.p2.<suffix>` definition.

## Helper

Run from Git Bash at workspace root:

```bash
./.copilot/skills/convert-p2-to-osgi-repo/scripts/convert-p2-to-osgi-repo.sh \
    eclipse_4.37_platform/cnf/ext/eclipse_4.37_platform.bnd
```

Use `--dry-run` to inspect the planned plugin name, index path, backup path,
and generated OSGiRepository block without network access or file mutation:

```bash
./.copilot/skills/convert-p2-to-osgi-repo/scripts/convert-p2-to-osgi-repo.sh \
    --dry-run eclipse_4.37_platform/cnf/ext/eclipse_4.37_platform.bnd
```

The helper accepts one explicit `.bnd` path. When the active editor is the
source of the request, resolve its path first and pass that path to the
helper. Set `BND_JAR` to override the default
`$HOME/biz.aQute.bnd.jar`.

## What It Does

1. Validate target path, plugin count, P2 URL, and existing conversion marker.
2. Copy the containing bnd workspace to a temporary directory.
3. For a repeat conversion, restore the retained P2 block only in that copy.
4. Remove copied P2 cache indexes so bnd must fetch current P2 metadata.
5. Run the bnd CLI repository listing command in the copied workspace.
6. Locate and validate the generated `cnf/cache/p2-*/index.xml.gz`.
7. Validate a temporary OSGiRepository configuration against that index.
8. Back up an existing destination index with a UTC timestamp.
9. Install the new index and replace the P2 block with a commented copy plus
   an active OSGiRepository block.
10. Validate the real workspace. On failure, restore the original `.bnd` file
    and original index.
11. Remove the `cnf/cache/ecl_*` directory created by that validation, so no
    build cache artifact is left behind.

The checked-in index is placed beside its source configuration:

```text
eclipse_4.37_platform/cnf/ext/eclipse_4.37_platform_index.xml.gz
```

The generated reference uses the same `.bnd` basename:

```properties
locations = '${fileuri;${.}/eclipse_4.37_platform_index.xml.gz}'
```

The original P2 block stays in the file as comments so the remote repository
can be regenerated later. Re-running the helper replaces its marked OSGi
block and creates another timestamped index backup.

## Precise bnd CLI Workflow

`repo index` is not the command for this task. It indexes local bundles. The
P2 provider creates its OSGi XML index when bnd first accesses the configured
P2 repository.

From the directory containing the standalone bnd workspace:

```bash
BND_JAR="$HOME/biz.aQute.bnd.jar"
WORKSPACE="eclipse_4.37_platform"

rm -rf "$WORKSPACE/cnf/cache/p2-"*
java -jar "$BND_JAR" repo -w "$WORKSPACE" list
find "$WORKSPACE/cnf/cache" -type f -path '*/p2-*/index.xml.gz' -print
```

`-w` belongs before `list`. Removing the provider cache index forces a fresh
download and conversion. `repo refresh` reinitializes repositories, but an
existing P2 cache index can be reused; delete that index before access when a
fresh conversion is required.

For a normal existing bnd installation:

```bash
java -jar "$HOME/biz.aQute.bnd.jar" version
```

Expected index format is OSGi Repository XML, gzip-compressed. The helper
checks gzip integrity and loads the index through `OSGiRepository` before
mutating the real workspace.

## Safety Rules

- Use Git Bash only. Do not translate commands to PowerShell or another shell.
- Process exactly one target `.bnd` file per invocation.
- Do not guess when multiple P2 blocks, malformed marked blocks, or an
  unmarked existing OSGi replacement is found.
- Existing destination indexes are moved beside themselves as
  `<stem>_YYYYMMDD-HHMMSS_index.xml.gz`; same-second collisions get a numeric
  suffix.
- Generation and validation happen in temporary copies. Failed runs leave the
  source configuration and destination index unchanged.
- The helper does not commit changes.