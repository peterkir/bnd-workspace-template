---
name: add-eclipse-release
description: >
  Add configuration files for a new Eclipse Platform release and/or SimRel
  release to the bnd-workspace-template repository. Use when a new Eclipse
  Platform or SimRel version needs `.bnd` files created, or when verifying
  release timestamps via download.eclipse.org composite metadata.
---

# add-eclipse-release

Add configuration files for a new Eclipse Platform release and/or SimRel release to the
bnd-workspace-template repository.

## Inputs

- `<pv>` — platform version, e.g. `4.38`
- `<sv>` — SimRel version, e.g. `2025-12`

Either can be supplied alone (e.g. platform released but SimRel not yet), or both together.

## Repository structure

```
eclipse_<pv>_platform/cnf/ext/eclipse_<pv>_platform.bnd
eclipse_<pv>_simrel_<sv>/cnf/ext/eclipse_<pv>_simrel_<sv>.bnd
```

## Key facts (verified)

- Platform update sites and SimRel repositories are both served from `download.eclipse.org`
  (NOT `archive.eclipse.org` — directory listing on download.eclipse.org is off, but the
  composite repository files work fine and are the reliable, default source for every
  version, old and new).
- Composite metadata is published as a **jar**, not a plain `.xml` file:
  `compositeContent.xml` returns 404 — the real file is `compositeContent.jar`
  (a zip containing `compositeContent.xml`).
- `p2.index` merely confirms the repository exists; the actual release timestamp/reltag
  must be read from the `child location` entries inside `compositeContent.jar`.

## Step-by-step

### 1. Verify the repository exists via p2.index

```bash
curl -Lk -s -o /dev/null -w "%{http_code}" \
  "https://download.eclipse.org/eclipse/updates/<pv>/p2.index"     # platform, expect 200
curl -Lk -s -o /dev/null -w "%{http_code}" \
  "https://download.eclipse.org/releases/<sv>/p2.index"            # simrel, expect 200
```

### 2. Download and extract compositeContent.jar to find the timestamp

**Platform:**
```bash
cd /tmp && rm -rf cc_platform && mkdir cc_platform && cd cc_platform
curl -Lk -s "https://download.eclipse.org/eclipse/updates/<pv>/compositeContent.jar" -o compositeContent.jar
unzip -o -q compositeContent.jar
cat compositeContent.xml
```
Look for `<child location='R-<pv>-<timestamp>'/>` — this is the platform reltag.
Example (4.38): `<child location='R-4.38-202512010920'/>`

**SimRel:**
```bash
cd /tmp && rm -rf cc_simrel && mkdir cc_simrel && cd cc_simrel
curl -Lk -s "https://download.eclipse.org/releases/<sv>/compositeContent.jar" -o compositeContent.jar
unzip -o -q compositeContent.jar
cat compositeContent.xml
```
The SimRel composite typically lists **two** children — a relative EPP-packages path
(`../../technology/epp/packages/<sv>/`, ignore it) and the real timestamp
(pure 12 digits, e.g. `202512101000`). Pick the pure-digit one.

### 3. Verify the platform reltag format

The reltag directory must be `R-<pv>-<timestamp>` where `<pv>` are the leading digits
(dots kept, e.g. `4.38`) and `<timestamp>` is a 12-digit suffix:

```bash
reltag="R-<pv>-<timestamp>"
[[ "$reltag" =~ ^R-<pv>-([0-9]{12})$ ]] && echo "OK: $BASH_REMATCH[1]" || echo "FAIL"
```

### 4. Create the platform bnd file

`eclipse_<pv>_platform/cnf/ext/eclipse_<pv>_platform.bnd`:

```bnd
# Eclipse Platform Release repository
eclipse.platform.baseurl = https://download.eclipse.org/eclipse/updates

eclipse.platform.version.<pv> = <pv>
eclipse.platform.reltag.R-<pv>-<timestamp> = R-<pv>-<timestamp>

-plugin.p2.eclipse.platform_<pv>: \
    aQute.bnd.repository.p2.provider.P2Repository; \
       name  = 'Eclipse P2 Platform ${eclipse.platform.version.<pv>}'; \
       url   = '${eclipse.platform.baseurl}/${eclipse.platform.version.<pv>}'
```

Note: the P2Repository `url` uses the **composite** URL (no reltag subpath) — bnd resolves
the actual release via the composite repository automatically. The reltag variable is kept
purely for provenance/documentation.

### 5. Create the SimRel bnd file

`eclipse_<pv>_simrel_<sv>/cnf/ext/eclipse_<pv>_simrel_<sv>.bnd`:

```bnd
# Eclipse Simultaneous Release repository 
eclipse.simrel.baseurl = https://download.eclipse.org/releases

eclipse.platform.version.<pv>      = <pv>
eclipse.simrel.version.<sv>        = <sv>
eclipse.simrel.reltag.<timestamp>  = <timestamp>

-plugin.p2.eclipse.simrel_<sv>: \
    aQute.bnd.repository.p2.provider.P2Repository; \
       name  = 'Eclipse P2 SimRel ${eclipse.platform.version.<pv>}/${eclipse.simrel.version.<sv>}'; \
       url   = '${eclipse.simrel.baseurl}/${eclipse.simrel.version.<sv>}'
```

## Version history (for reference)

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

## After adding files

Append the new row to the version history table above so future runs of this skill have
an up-to-date reference.
