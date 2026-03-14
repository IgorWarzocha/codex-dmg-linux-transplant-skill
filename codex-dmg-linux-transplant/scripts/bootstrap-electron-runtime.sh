#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo 'usage: bootstrap-electron-runtime.sh <stage-dir> <electron-version>' >&2
  exit 1
fi

stage_dir="$1"
electron_version="$2"

if ! command -v npm >/dev/null 2>&1; then
  echo 'npm is required' >&2
  exit 1
fi

mkdir -p "$stage_dir/electron"
if [[ ! -f "$stage_dir/electron/package.json" ]]; then
  printf '{"private":true}\n' > "$stage_dir/electron/package.json"
fi

npm install --prefix "$stage_dir/electron" --no-save "electron@${electron_version}"

echo "$stage_dir/electron/node_modules/electron/dist/electron"
