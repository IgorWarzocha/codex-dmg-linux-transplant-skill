#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo 'usage: install-codex-cli.sh <stage-dir>' >&2
  exit 1
fi

stage_dir="$1"
cli_dir="$stage_dir/cli"
mkdir -p "$cli_dir"

if [[ ! -f "$cli_dir/package.json" ]]; then
  printf '{"private":true}\n' > "$cli_dir/package.json"
fi

npm install --prefix "$cli_dir" --no-save @openai/codex

if [[ ! -x "$cli_dir/node_modules/.bin/codex" ]]; then
  echo 'failed to install local codex cli' >&2
  exit 1
fi

echo "$cli_dir/node_modules/.bin/codex"
