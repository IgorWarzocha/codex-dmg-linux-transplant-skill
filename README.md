# Codex DMG Linux Transplant Skill

This skill installs or updates **Codex Desktop on Linux from `Codex.dmg`** when no official Linux build exists.

It is designed for two cases:

- fresh install on a machine with no Codex desktop app
- updating an existing transplanted install to a newer DMG build

What it does:

- checks the current system first
- finds a local DMG or uses the default Codex DMG URL
- extracts the app metadata and default app icon from the DMG
- prepares a Linux desktop install
- installs Codex as the **main desktop version**, not as a side-by-side extra copy
- bundles a Linux Codex CLI path instead of assuming one already exists
- automatically patches the transplanted app to force-enable desktop UI flags
- verifies that the installed wrapper actually launches

Desktop flag patching currently targets:

- avatar overlay
- ambient suggestions
- artifacts pane
- browser pane
- multi-window
- projectless threads

Default DMG source:

- `https://persistent.oaistatic.com/codex-app-prod/Codex.dmg`

Everything else is documented inside the skill files.
