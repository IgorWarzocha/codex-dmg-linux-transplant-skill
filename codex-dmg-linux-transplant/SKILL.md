---
name: codex-dmg-linux-transplant
description: Install or update Codex Desktop on Linux from a Codex.dmg when no official Linux build exists. Use when the user wants a clean install or update from a DMG, wants the DMG found in Downloads or elsewhere, or wants the new build installed as the single main Codex desktop version.
---

# Codex DMG → Linux Transplant

Use this skill for Codex Desktop install/update work when the source artifact is a macOS `Codex.dmg` and Linux needs a transplanted desktop build.

## Non-negotiable rules

1. **Assume there is no usable Codex desktop install already.** Never rely on an existing community port being present.
2. **Always probe the system first.** Read `references/system-checks.md` and run `scripts/probe-system.sh` before changing anything.
3. **Install one main version only.** The target layout is:
   - `~/.local/opt/codex-desktop`
   - `~/.local/bin/codex-desktop`
   - `~/.local/share/applications/codex-desktop.desktop`
4. **No side-by-side versioned launchers** unless the user explicitly asks for them.
5. **DMG source order:** user-supplied path → search Downloads and nearby folders → default URL `https://persistent.oaistatic.com/codex-app-prod/Codex.dmg`.
6. **Fail fast if prerequisites are missing.** Do not pretend the transplant is complete if native modules or Electron runtime are missing.

## Required reading order

1. `references/workflow.md`
2. `references/system-checks.md`
3. `references/native-modules.md`
4. `references/install-layout.md`

## Default workflow

### 1) Probe the machine
Run:

```bash
./scripts/probe-system.sh
```

Confirm at minimum:
- distro and package manager
- `python3`, `node`, `npm`, `git`, `curl`
- build tools like `gcc`, `g++`, `make`
- `7z` for DMG extraction
- any existing Codex launchers or directories that must be replaced

### 2) Locate or fetch the DMG
Use a user path if provided. Otherwise search safely with `find`. If nothing suitable exists, download the default DMG URL.

### 3) Extract metadata from the DMG
Run:

```bash
python ./scripts/extract-codex-dmg-metadata.py /path/to/Codex.dmg
```

This prints JSON with the app version, build number, Electron version, and key dependency versions.

### 4) Build a Linux host bundle from scratch
Never assume an older Codex port exists.

Bootstrap a self-contained Electron runtime:

```bash
./scripts/bootstrap-electron-runtime.sh /tmp/codex-stage <electron-version>
```

Then rebuild Linux-native modules:

```bash
./scripts/rebuild-native-modules.sh /tmp/codex-stage <electron-version> <better-sqlite3-version> <node-pty-version>
```

Copy the DMG's `app.asar` into `/tmp/codex-stage/resources/app.asar` before rebuilding/writing the final layout.

### 5) Install as the main desktop version
Write the final app layout with:

```bash
./scripts/write-main-install.sh /tmp/codex-stage <app-version> <build-number>
```

This installs the main version at the fixed locations in `~/.local`.

### 6) Replace old launchers only after verification
After the new install launches successfully, remove or disable older Codex desktop shims, versioned launchers, and stale desktop entries so the user ends up with one main Codex launcher.

### 7) Verify
At minimum verify:
- `~/.local/bin/codex-desktop` exists and is executable
- desktop entry points to the main wrapper
- the app launches under the rebuilt runtime
- no stale `codex-desktop-*` launchers remain unless user asked to keep them

## Notes

- If launch fails with a missing native module, inspect the error and rebuild the missing Linux-native dependency instead of copying mac binaries.
- If `7z` is missing, install it before doing anything else with the DMG.
- If the machine lacks build tools, install them first; the transplant is not complete without native module rebuilds.
