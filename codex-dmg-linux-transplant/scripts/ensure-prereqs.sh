#!/usr/bin/env bash
set -euo pipefail

missing=()
for cmd in python3 node npm git curl 7z gcc g++ make; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

if [[ ${#missing[@]} -eq 0 ]]; then
  echo 'all core prerequisites already installed'
  exit 0
fi

echo "missing prerequisites: ${missing[*]}"

if command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --needed --noconfirm base-devel python nodejs npm git curl p7zip
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y build-essential python3 python3-venv python3-pip nodejs npm git curl p7zip-full
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y gcc gcc-c++ make python3 python3-pip nodejs npm git curl p7zip p7zip-plugins
elif command -v zypper >/dev/null 2>&1; then
  sudo zypper install -y gcc gcc-c++ make python3 python3-pip nodejs npm git curl p7zip
else
  echo 'unsupported package manager for automatic prerequisite install' >&2
  exit 1
fi

echo 'prerequisite install step completed'
