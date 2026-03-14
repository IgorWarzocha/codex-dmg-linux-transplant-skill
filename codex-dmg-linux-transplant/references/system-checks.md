# System Checks

Always inspect the machine before planning the transplant.

## Required probes

Run:

```bash
../scripts/probe-system.sh
```

That probe should confirm:

- OS and distro from `/etc/os-release`
- architecture from `uname -m`
- available package manager(s)
- required tools:
  - `python3`
  - `node`
  - `npm`
  - `git`
  - `curl`
  - `7z`
- build tools:
  - `gcc`
  - `g++`
  - `make`
- existing Electron binaries, if any
- existing Codex launchers, desktop files, and install directories

## Fail-fast rules

Do not continue until these exist:

- `python3`
- `node`
- `npm`
- `7z`
- a working C/C++ toolchain for native rebuilds

## Existing install inspection

The user asked for a single main desktop version. Check and later clean up:

- `~/.local/bin/codex-desktop*`
- `~/.local/share/applications/*codex*.desktop`
- `~/.local/opt/codex-desktop*`
- `/opt/codex-desktop*`
- `/usr/bin/codex-desktop`

## DMG extraction requirement

`7z` is the preferred path for extracting `Info.plist` and `app.asar` from `Codex.dmg`.

If `7z` is not present, install it first.
