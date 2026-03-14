#!/usr/bin/env python3
import json
import os
import plistlib
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def run(cmd):
    return subprocess.run(cmd, check=True, capture_output=True)


def load_asar_package_json(path: Path):
    with path.open('rb') as f:
        vals = [int.from_bytes(f.read(4), 'little') for _ in range(4)]
        json_len = vals[3]
        header = json.loads(f.read(json_len))
        node = header['files']['package.json']
        base = 8 + vals[1]
        f.seek(base + int(node['offset']))
        data = f.read(node['size'])
    return json.loads(data.decode('utf-8'))


def main():
    if len(sys.argv) != 2:
        raise SystemExit('usage: extract-codex-dmg-metadata.py /path/to/Codex.dmg')
    dmg = Path(sys.argv[1]).expanduser().resolve()
    if not dmg.exists():
        raise SystemExit(f'dmg not found: {dmg}')
    if shutil.which('7z') is None:
        raise SystemExit('7z is required')

    with tempfile.TemporaryDirectory() as td:
        out = Path(td)
        run(['7z', 'x', str(dmg), '-ir!Codex Installer/Codex.app/Contents/Info.plist', '-y', f'-o{out}'])
        run(['7z', 'x', str(dmg), '-ir!Codex Installer/Codex.app/Contents/Resources/app.asar', '-y', f'-o{out}'])

        plist_path = out / 'Codex Installer' / 'Codex.app' / 'Contents' / 'Info.plist'
        asar_path = out / 'Codex Installer' / 'Codex.app' / 'Contents' / 'Resources' / 'app.asar'

        info = plistlib.load(plist_path.open('rb'))
        pkg = load_asar_package_json(asar_path)

        result = {
            'dmg_path': str(dmg),
            'app_version': pkg.get('version') or info.get('CFBundleShortVersionString'),
            'build_number': pkg.get('codexBuildNumber') or info.get('CFBundleVersion'),
            'electron_version': (pkg.get('devDependencies') or {}).get('electron'),
            'better_sqlite3_version': (pkg.get('dependencies') or {}).get('better-sqlite3'),
            'node_pty_version': (pkg.get('dependencies') or {}).get('node-pty'),
            'bundle_identifier': info.get('CFBundleIdentifier'),
            'bundle_version': info.get('CFBundleVersion'),
            'bundle_short_version': info.get('CFBundleShortVersionString'),
        }
        print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
