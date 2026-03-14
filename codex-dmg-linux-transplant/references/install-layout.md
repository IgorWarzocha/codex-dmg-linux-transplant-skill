# Install Layout

The final install must be the single main Codex Desktop version.

## Fixed target paths

Install to:

```text
~/.local/opt/codex-desktop
~/.local/bin/codex-desktop
~/.local/share/applications/codex-desktop.desktop
```

## Why fixed paths

Use fixed paths so updates replace the main install instead of creating side-by-side versioned shims.

## Expected app directory

```text
~/.local/opt/codex-desktop/
├── electron/
│   └── node_modules/electron/
├── package.json
└── resources/
    ├── app.asar
    └── app.asar.unpacked/
```

## Wrapper requirements

The wrapper should:

- set `ELECTRON_FORCE_IS_PACKAGED=1`
- prefer the global `codex` CLI if present
- launch the self-contained Electron runtime from the app directory
- pass Wayland flags when appropriate

## Desktop entry requirements

The desktop file should:

- point to `~/.local/bin/codex-desktop`
- use the plain app name `Codex`
- replace older user-local Codex desktop entries after verification

## Cleanup after successful install

After the new install is verified, remove stale items such as:

- `~/.local/bin/codex-desktop-*`
- `~/.local/share/applications/codex-desktop-*.desktop`
- old versioned `~/.local/opt/codex-desktop-*` directories

Only keep alternates if the user explicitly asks.
