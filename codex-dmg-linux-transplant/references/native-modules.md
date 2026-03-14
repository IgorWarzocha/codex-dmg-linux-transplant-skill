# Native Modules

The DMG only gives you the app bundle and mac-native binaries. Linux needs its own rebuilt native modules.

## What carries over from the DMG

These are usually portable enough to reuse:

- `resources/app.asar`
- metadata such as app version and build number

## What must be Linux-native

Do not reuse mac binaries for Linux:

- `.node` addons
- helper executables
- platform-specific runtime pieces

## Known critical modules

From the Codex DMG builds inspected so far, the main Linux rebuild targets are:

- `better-sqlite3`
- `node-pty`

## Why rebuilds are required

Native addons must match all of these:

- Linux OS
- target CPU architecture
- Electron ABI
- the Electron version used to launch the app

## Rebuild strategy

Use the Electron version extracted from the DMG metadata and rebuild with:

- `npm_config_runtime=electron`
- `npm_config_target=<electron-version>`
- `npm_config_disturl=https://electronjs.org/headers`
- `npm_config_build_from_source=true`

The helper script `../scripts/rebuild-native-modules.sh` does this for the known critical modules.

## If launch still fails

Inspect the actual missing-module error.

Common outcomes:
- missing `.node` addon: rebuild/add that package to `app.asar.unpacked`
- ABI mismatch: rebuild against the correct Electron version
- wrong runtime path: fix the wrapper to use the intended Electron binary

Do not paper over missing Linux-native dependencies by copying mac binaries.
