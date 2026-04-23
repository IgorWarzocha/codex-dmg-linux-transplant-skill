# Desktop Flags Patch

This skill now patches the installed app to force-enable desktop-only flags in the renderer after the main install is written.

## Current forced desktop flags

- `avatarOverlay`
- `ambientSuggestions`
- `artifactsPane`
- `browserPane`
- `multiWindow`
- `projectlessThreads`

## Script

Use:

```bash
../scripts/patch-desktop-flags.sh ~/.local/opt/codex-desktop
```

The script extracts `resources/app.asar`, tolerates missing unpacked dev-only files by creating placeholders when needed, patches the renderer bundle, and repacks `app.asar` while preserving unpacked native modules.

## Automatic application

`../scripts/write-main-install.sh` now invokes the desktop flag patch automatically after installing the app layout.
