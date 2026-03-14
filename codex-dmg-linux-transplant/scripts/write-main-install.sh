#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo 'usage: write-main-install.sh <stage-dir> <app-version> <build-number>' >&2
  exit 1
fi

stage_dir="$1"
app_version="$2"
build_number="$3"
final_dir="$HOME/.local/opt/codex-desktop"
wrapper_path="$HOME/.local/bin/codex-desktop"
desktop_path="$HOME/.local/share/applications/codex-desktop.desktop"
backup_dir="${final_dir}.backup.$(date +%s)"

electron_bin='$HOME/.local/opt/codex-desktop/electron/node_modules/electron/dist/electron'

mkdir -p "$HOME/.local/opt" "$HOME/.local/bin" "$HOME/.local/share/applications"

if [[ ! -f "$stage_dir/resources/app.asar" ]]; then
  echo 'stage_dir is missing resources/app.asar' >&2
  exit 1
fi

if [[ -d "$final_dir" ]]; then
  mv "$final_dir" "$backup_dir"
fi
mv "$stage_dir" "$final_dir"

cat > "$final_dir/package.json" <<EOF
{
  "name": "openai-codex-electron-linux-shim",
  "productName": "Codex",
  "version": "${app_version}",
  "description": "OpenAI Codex Desktop Linux transplant from DMG",
  "main": "resources/app.asar",
  "codexBuildFlavor": "prod",
  "codexBuildNumber": "${build_number}"
}
EOF

cat > "$wrapper_path" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

export ELECTRON_FORCE_IS_PACKAGED=1

if [[ -z "${CODEX_CLI_PATH-}" ]] && command -v codex >/dev/null 2>&1; then
  export CODEX_CLI_PATH="$(command -v codex)"
fi

extra_flags=()
if [[ -n "${WAYLAND_DISPLAY-}" || "${XDG_SESSION_TYPE-}" == "wayland" ]]; then
  extra_flags+=(--enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=wayland)
else
  extra_flags+=(--ozone-platform-hint=auto)
fi

exec "$HOME/.local/opt/codex-desktop/electron/node_modules/electron/dist/electron" "${extra_flags[@]}" "$HOME/.local/opt/codex-desktop/resources/app.asar" "$@"
EOF
chmod +x "$wrapper_path"

cat > "$desktop_path" <<EOF
[Desktop Entry]
Type=Application
Name=Codex
Comment=OpenAI Codex Desktop
Exec=${wrapper_path} %U
Terminal=false
Categories=Development;
StartupWMClass=Codex
MimeType=x-scheme-handler/codex;
EOF

echo "installed to $final_dir"
if [[ -d "$backup_dir" ]]; then
  echo "backup saved to $backup_dir"
fi
