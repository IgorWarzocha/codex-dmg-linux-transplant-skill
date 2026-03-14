# Workflow

This skill installs or updates Codex Desktop on Linux from a macOS `Codex.dmg` without assuming any existing Codex desktop install.

## Goal

Produce one main Linux install at:

- `~/.local/opt/codex-desktop`
- `~/.local/bin/codex-desktop`
- `~/.local/share/applications/codex-desktop.desktop`

## Source resolution order

1. User-provided DMG path
2. Search likely locations, for example:
   - `~/Downloads`
   - `~/Downloads/00-inbox`
   - any explicit path the user mentions
3. If not found, download:
   - `https://persistent.oaistatic.com/codex-app-prod/Codex.dmg`

## End-to-end sequence

1. Probe the machine with `../scripts/probe-system.sh`
2. Resolve the DMG path
3. Extract metadata with `../scripts/extract-codex-dmg-metadata.py`
4. Extract `app.asar` from the DMG into a staging directory
5. Bootstrap a self-contained Electron runtime with `../scripts/bootstrap-electron-runtime.sh`
6. Rebuild Linux-native modules with `../scripts/rebuild-native-modules.sh`
7. Write the main install layout with `../scripts/write-main-install.sh`
8. Launch and verify
9. Remove stale Codex launchers and old shims after verification

## Staging layout

A typical staging directory should look like:

```text
/tmp/codex-stage/
├── electron/
│   └── node_modules/electron/
└── resources/
    ├── app.asar
    └── app.asar.unpacked/
        └── node_modules/
```

## Verification checklist

- Wrapper launches from `~/.local/bin/codex-desktop`
- Desktop entry points to the wrapper
- `resources/app.asar` matches the new DMG build
- `resources/app.asar.unpacked` contains rebuilt Linux-native modules
- old versioned launchers are removed unless explicitly requested
