---
name: add-eclipse-release
description: >
  Add configuration files for a new Eclipse Platform release and/or SimRel
  release to the bnd-workspace-template repository. Use when a new Eclipse
  Platform or SimRel version needs `.bnd` files created, or when verifying
  release timestamps via download.eclipse.org composite metadata.
---

# add-eclipse-release

Add Eclipse Platform and/or SimRel repository fragments with selectable P2 and
indexed OSGi repository backends.

## Inputs

- `<pv>` - platform version, for example `4.40`
- `<sv>` - SimRel version, for example `2026-06`

Either value can be supplied alone.

## Fragment structure

Each release fragment contains the repository configuration, its switch, and,
for indexed mode, a checked-in OSGi repository index:

```
eclipse_<pv>_platform/cnf/ext/eclipse_<pv>_platform.bnd
eclipse_<pv>_platform/cnf/ext/eclipse-repo-config.bnd
eclipse_<pv>_platform/cnf/ext/eclipse_${eclipse.platform.version.<pv>}_platform_p2.index.xml.gz/index.xml.gz

eclipse_<pv>_simrel_<sv>/cnf/ext/eclipse_<pv>_simrel_<sv>.bnd
eclipse_<pv>_simrel_<sv>/cnf/ext/eclipse-repo-config.bnd
eclipse_<pv>_simrel_<sv>/cnf/ext/eclipse_${eclipse.platform.version.<pv>}_simrel_${eclipse.simrel.version.<sv>}_p2.index.xml.gz/index.xml.gz
```

`cnf/ext` files load automatically in a bnd workspace. Create
`eclipse-repo-config.bnd` with:

```properties
useIndexed = true
```

`useIndexed=true` selects the checked-in `OSGiRepository`. Set it to `false`
to select the remote `P2Repository`. Both `-plugin.*` properties must remain
active; their values use the switch to expose only one backend.

## Release metadata

Platform update sites and SimRel repositories use `download.eclipse.org`.
Verify each repository before creating its fragment:

```bash
curl -Lk -s -o /dev/null -w "%{http_code}" \
  "https://download.eclipse.org/eclipse/updates/<pv>/p2.index"
curl -Lk -s -o /dev/null -w "%{http_code}" \
  "https://download.eclipse.org/releases/<sv>/p2.index"
```

Read release timestamps from `compositeContent.jar`, not
`compositeContent.xml`:

```bash
work=$(mktemp -d)
curl -Lk -s "https://download.eclipse.org/eclipse/updates/<pv>/compositeContent.jar" \
  -o "$work/platform.jar"
unzip -p "$work/platform.jar" compositeContent.xml
curl -Lk -s "https://download.eclipse.org/releases/<sv>/compositeContent.jar" \
  -o "$work/simrel.jar"
unzip -p "$work/simrel.jar" compositeContent.xml
rm -rf "$work"
```

The platform child location has the form `R-<pv>-<timestamp>`. SimRel
metadata normally contains an EPP relative path and one pure 12-digit
location; use the pure-digit location.

## Platform configuration

Create `eclipse_<pv>_platform/cnf/ext/eclipse_<pv>_platform.bnd`:

```bnd
# Eclipse Platform Release repository
eclipse.platform.baseurl = https://download.eclipse.org/eclipse/updates

eclipse.platform.version.<pv> = <pv>
eclipse.platform.reltag.R-<pv>-<timestamp> = R-<pv>-<timestamp>

eclipse.p2.repository.<pv>: \
    aQute.bnd.repository.p2.provider.P2Repository; \
        name     = 'Eclipse P2 Platform ${eclipse.platform.version.<pv>}'; \
        url      = '${eclipse.platform.baseurl}/${eclipse.platform.version.<pv>}'; \
        location = '${.}/eclipse_${eclipse.platform.version.<pv>}_platform_p2.index.xml.gz'

eclipse.osgi.repository.<pv>: \
    aQute.bnd.repository.osgi.OSGiRepository; \
        name      = 'Eclipse Platform ${eclipse.platform.version.<pv>}'; \
        locations = '${fileuri;${.}/eclipse_${eclipse.platform.version.<pv>}_platform_p2.index.xml.gz/index.xml.gz}'; \
        cache     = '${build}/cache/ecl_${eclipse.platform.version.<pv>}'

-plugin.p2.eclipse.platform_<pv>: ${if;${useIndexed};;${eclipse.p2.repository.<pv>}}
-plugin.osgi.eclipse.platform_<pv>: ${if;${useIndexed};${eclipse.osgi.repository.<pv>};}
```

## SimRel configuration

Create `eclipse_<pv>_simrel_<sv>/cnf/ext/eclipse_<pv>_simrel_<sv>.bnd`:

```bnd
# Eclipse Simultaneous Release repository
eclipse.simrel.baseurl = https://download.eclipse.org/releases

eclipse.platform.version.<pv> = <pv>
eclipse.simrel.version.<sv> = <sv>
eclipse.simrel.reltag.<timestamp> = <timestamp>
eclipse.p2.repository.<sv>: \
    aQute.bnd.repository.p2.provider.P2Repository; \
        name     = 'Eclipse P2 SimRel ${eclipse.platform.version.<pv>}/${eclipse.simrel.version.<sv>}'; \
        url      = '${eclipse.simrel.baseurl}/${eclipse.simrel.version.<sv>}'; \
        location = '${.}/eclipse_${eclipse.platform.version.<pv>}_simrel_${eclipse.simrel.version.<sv>}_p2.index.xml.gz'

eclipse.osgi.repository.<sv>: \
    aQute.bnd.repository.osgi.OSGiRepository; \
        name      = 'Eclipse SimRel ${eclipse.platform.version.<pv>}/${eclipse.simrel.version.<sv>}'; \
        locations = '${fileuri;${.}/eclipse_${eclipse.platform.version.<pv>}_simrel_${eclipse.simrel.version.<sv>}_p2.index.xml.gz/index.xml.gz}'; \
        cache     = '${build}/cache/ecl_${eclipse.platform.version.<pv>}'

-plugin.p2.eclipse.simrel_<sv>: ${if;${useIndexed};;${eclipse.p2.repository.<sv>}}
-plugin.osgi.eclipse.simrel_<sv>: ${if;${useIndexed};${eclipse.osgi.repository.<sv>};}
```

The P2 `location` is a macro-derived directory whose name ends in
`_p2.index.xml.gz`. bnd writes `index.xml.gz` and downloaded bundles below it;
the suffix is part of the directory name, not the final generated file. The
OSGi `locations` value points to that exact generated index in the same
directory.

## Creating the checked-in index

To create or refresh an indexed release, use a temporary bnd workspace with an
empty `cnf/build.bnd`, set `useIndexed=false`, and access the repository:

```bash
java -jar "$HOME/biz.aQute.bnd.jar" repo -w <temporary-release-workspace> list
```

Keep the generated file from the P2 cache directory at the configured location:

```text
cnf/ext/eclipse_${eclipse.platform.version.<pv>}_platform_p2.index.xml.gz/index.xml.gz
```

Remove downloaded bundle files from the P2 cache directory, restore
`useIndexed=true`, and verify that the indexed backend loads:

```bash
java -jar "$HOME/biz.aQute.bnd.jar" repo -w <release-workspace> list
```

Do not add generated cache directories or conversion markers to release
fragments.

## Version history

| Platform | SimRel  | Platform reltag           | SimRel reltag   |
|----------|---------|----------------------------|-----------------|
| 4.30     | 2023-12 | R-4.30-202312010110         | 202312061001    |
| 4.31     | 2024-03 | R-4.31-202402290520         | 202403131000    |
| 4.32     | 2024-06 | R-4.32-202406010610         | 202406121000    |
| 4.33     | 2024-09 | R-4.33-202409030240         | 202409111000    |
| 4.34     | 2024-12 | R-4.34-202411201800         | 202412041000    |
| 4.35     | 2025-03 | R-4.35-202502280140         | 202503121000    |
| 4.36     | 2025-06 | R-4.36-202505281830         | 202506111000    |
| 4.37     | 2025-09 | R-4.37-202509050730         | 202509101001    |
| 4.38     | 2025-12 | R-4.38-202512010920         | 202512101000    |
| 4.39     | 2026-03 | R-4.39-202602260420         | 202603111000    |
| 4.40     | 2026-06 | R-4.40-202606010713         | 202606101000    |
```
