#!/usr/bin/env bash
# Automated Gradia installation for Ubuntu and other Debian-based distros
# - Prefers snap on Ubuntu (sudo snap install gradia)
# - Falls back to flatpak (flathub be.alexandervanhee.gradia) where snap is unavailable
# - Skips if Gradia is already installed via either package system
set -euo pipefail

SNAP_NAME="gradia"
FLATPAK_ID="be.alexandervanhee.gradia"

# --- Check if Gradia is already installed (snap or flatpak) ---
if snap list "$SNAP_NAME" >/dev/null 2>&1; then
    echo ">>> Gradia is already installed via snap."
    exit 0
fi

if flatpak list --app 2>/dev/null | grep -q "$FLATPAK_ID"; then
    echo ">>> Gradia is already installed via flatpak."
    exit 0
fi

# --- Install via snap (preferred on Ubuntu) ---
if command -v snap >/dev/null 2>&1; then
    echo ">>> Installing Gradia via snap..."
    sudo snap install "$SNAP_NAME"

# --- Fall back to flatpak on distros without snap ---
elif command -v flatpak >/dev/null 2>&1; then
    echo ">>> Installing Gradia via flatpak..."
    flatpak install -y flathub "$FLATPAK_ID"

else
    echo "ERROR: Neither snap nor flatpak found. Install one of them first." >&2
    exit 1
fi

echo ">>> Done. Gradia should now be available in your applications menu."
