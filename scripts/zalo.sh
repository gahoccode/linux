#!/usr/bin/env bash
# Prerequisites + automated Zalo installation
# - Installs Gear Lever (Flatpak) if not already installed: prefers a local
#   offline bundle when present, otherwise installs from flathub
# - Downloads the Zalo AppImage (with ZaDark)
# - Integrates it into the system via Gear Lever
set -euo pipefail

FLATPAK_BUNDLE="$HOME/Downloads/gearlever-4.6.2-x86_64.flatpak"
ZALO_APPIMAGE="Zalo-26.8.20+ZaDark-26.2.1-ecfb96a-ZaDark.AppImage"
ZALO_URL="https://github.com/doandat943/zalo-for-linux/releases/download/26.8.20/${ZALO_APPIMAGE}"

cd "$HOME/Downloads"

# --- Prerequisite: install Gear Lever if missing ---
if ! flatpak list --user 2>/dev/null | grep -q "it.mijorus.gearlever"; then
    # The flathub remote serves the app and the GNOME runtime both paths need.
    flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    if [[ -f "$FLATPAK_BUNDLE" ]]; then
        echo ">>> Installing Gear Lever from local bundle..."
        flatpak install --user --bundle --assumeyes "$FLATPAK_BUNDLE"
    else
        echo ">>> Installing Gear Lever from flathub..."
        flatpak install --user -y flathub it.mijorus.gearlever
    fi
else
    echo ">>> Gear Lever is already installed."
fi

# --- Download the AppImage (skip if already present) ---
if [[ ! -f "$ZALO_APPIMAGE" ]]; then
    echo ">>> Downloading Zalo AppImage..."
    wget "$ZALO_URL"
else
    echo ">>> Zalo AppImage already downloaded."
fi

# --- Install with Gear Lever ---
echo ">>> Integrating Zalo AppImage with Gear Lever..."
flatpak run it.mijorus.gearlever --integrate -y "$ZALO_APPIMAGE"

echo ">>> Done. Zalo should now be available in your applications menu."
