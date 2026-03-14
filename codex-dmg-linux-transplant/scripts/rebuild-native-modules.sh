#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo 'usage: rebuild-native-modules.sh <stage-dir> <electron-version> <better-sqlite3-version> <node-pty-version>' >&2
  exit 1
fi

stage_dir="$1"
electron_version="$2"
better_sqlite3_version="$3"
node_pty_version="$4"
build_dir="$stage_dir/native-build"

for cmd in npm node python3 gcc g++ make; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing required tool: $cmd" >&2
    exit 1
  fi
done

rm -rf "$build_dir"
mkdir -p "$build_dir" "$stage_dir/resources/app.asar.unpacked/node_modules"
printf '{"private":true}\n' > "$build_dir/package.json"

npm install --prefix "$build_dir" --no-save @electron/rebuild \
  "better-sqlite3@${better_sqlite3_version}" \
  "node-pty@${node_pty_version}"

"$build_dir/node_modules/.bin/electron-rebuild" -f -v "$electron_version" -w better-sqlite3,node-pty --module-dir "$build_dir"

rm -rf "$stage_dir/resources/app.asar.unpacked/node_modules/better-sqlite3"
rm -rf "$stage_dir/resources/app.asar.unpacked/node_modules/node-pty"
cp -a "$build_dir/node_modules/better-sqlite3" "$stage_dir/resources/app.asar.unpacked/node_modules/"
cp -a "$build_dir/node_modules/node-pty" "$stage_dir/resources/app.asar.unpacked/node_modules/"

echo 'rebuilt native modules into app.asar.unpacked'
