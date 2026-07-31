# Inventable Technology Releases

Public binary downloads for Inventable Technology software and approved device
firmware. Product source code remains in its corresponding source repository.

## Northstar Gauge Interface

Download the current Windows installer from the
[latest GitHub Release](https://github.com/Inventable/IT_Releases/releases/latest).
The installer is self-contained and does not require a separate .NET runtime.

The current `1.0.1` installer is unsigned and intended for controlled testing.
Windows will display an unknown-publisher warning until release signing is
introduced.

## Update catalogue

`channels/stable.json` is the machine-readable release catalogue used by the
Gauge Interface. Large installer and firmware files are immutable GitHub
Release assets. Publish every asset before changing the stable catalogue.

Firmware entries are added only after the private firmware repository has
produced a clean, tested universal Offset-production release. Combined,
StandAlone, unified, and programmer images are never client update assets.

## Repository layout

```text
README.md
channels/
  stable.json
schemas/
  release-manifest.schema.json
.github/
  workflows/
    validate-release.yml
```
