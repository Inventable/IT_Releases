# Northstar Gauge Releases

Public, binary-only downloads for Northstar Gauge Interface and approved gauge
firmware. Source code lives in separate repositories.

## Download the Windows application

For normal customer deployment, open the latest stable GitHub Release and
download `Northstar-Gauge-Interface-Setup-<version>.exe`. The installer includes
the .NET runtime and does not require a separate framework installation.

Engineering beta releases are published as GitHub prereleases. Their assets are
listed by `channels/beta/current.json`; the engineering-beta application reads
that catalogue so a complete beta suite can be evaluated without changing the
stable channel.

## Firmware catalogues

The production application reads `channels/stable.json`, selects the newest
stable entry matching the connected gauge device type or compatible
memory-gauge family, downloads the referenced Offset-production HEX, verifies
its SHA-256, and validates the image layout before programming is enabled.

The engineering-beta application reads `channels/beta/current.json`. A beta
manifest identifies one immutable suite, including the Windows application,
production Offset firmware and supporting engineering assets. Publishing a beta
does not modify `channels/stable.json`.

Published release files are immutable: correcting an artifact requires a new
version and new GitHub Release assets. `SHA256SUMS.txt` records hashes for
human and offline verification.

When more than one beta is published on the same day, the suite version adds a
numeric prerelease revision, for example `2026.8.12-beta.1`.

## Repository layout

```text
README.md
channels/
  stable.json
  beta/
    current.json
schemas/
  release-manifest.schema.json
  beta-release-manifest.schema.json
eng/
  Test-ReleaseRepository.ps1
.github/
  workflows/
    validate-release.yml
```

The application catalogues use the public repository
`Inventable/IT_Releases`. Installer and HEX binaries belong in GitHub Release
assets, not Git history.
