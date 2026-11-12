#!/usr/bin/env bash
#
# Automates the setup described in office-productivity/linux-office.md:
# Microsoft core fonts for OnlyOffice, then the fcitx5-lotus Vietnamese
# input method on Ubuntu.
#
# Usage:
#   ./linux-office-setup.sh
#
# No prompts, lotus-only. Run as a normal user; the script calls sudo
# itself. Safe to re-run: the repository line is only written once. In a
# non-interactive shell without cached sudo credentials it fails fast
# instead of hanging.
#
# Disabling the old IBus input method and declaring the input-method
# environment variables in ~/.bash_profile (steps 7-8 of the note) live
# in their own script: disable-ibus.sh.
#
# Sources:
#   - Video guide (lotus): https://www.youtube.com/watch?v=WBd8iy-bePA
#   - Official lotus docs: https://lotusinputmethod.github.io/#installation
#
# Steps that cannot be automated are printed at the end:
#   - adding the engine in fcitx5-configtool
#   - enabling autostart via GNOME Tweaks
#   - logging out and back in so ~/.bash_profile (written by
#     disable-ibus.sh) takes effect

set -euo pipefail

say() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

if [ "$(id -u)" -eq 0 ]; then
    die "Run as a normal user, not with sudo; the script invokes sudo itself."
fi

# --- 0. Sudo guard ------------------------------------------------------------

# Fail fast when an agent runs us without a tty and without cached sudo
# credentials, instead of hanging on a password prompt.
if [ ! -t 0 ] && ! sudo -n true 2>/dev/null; then
    die "non-interactive shell without cached sudo credentials; run 'sudo -v' in your terminal first, then retry"
fi

say "Input method: fcitx5-lotus"

LOTUS_KEYRING="/etc/apt/keyrings/fcitx5-lotus.gpg"
LOTUS_LIST="/etc/apt/sources.list.d/fcitx5-lotus.list"
LOTUS_SERVICE="fcitx5-lotus-server@$(whoami).service"

# --- 1. Fonts: Times New Roman for OnlyOffice --------------------------------

say "Installing Microsoft core fonts (ttf-mscorefonts-installer)"
sudo apt-get update
# Preseed EULA acceptance so the installer does not block the run.
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" |
    sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ttf-mscorefonts-installer curl gnupg

# --- 2. Vietnamese input method ----------------------------------------------

CODENAME="$(grep '^UBUNTU_CODENAME=' /etc/os-release | cut -d'=' -f2 || true)"
[ -n "$CODENAME" ] || die "UBUNTU_CODENAME not found in /etc/os-release (this script targets Ubuntu)"

say "Adding fcitx5-lotus repository for '$CODENAME'"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://fcitx5-lotus.pages.dev/pubkey.gpg |
    sudo gpg --yes --dearmor -o "$LOTUS_KEYRING"
REPO_LINE="deb [signed-by=$LOTUS_KEYRING] https://fcitx5-lotus.pages.dev/apt/$CODENAME $CODENAME main"
grep -qxF "$REPO_LINE" "$LOTUS_LIST" 2>/dev/null || echo "$REPO_LINE" | sudo tee "$LOTUS_LIST"

say "Installing fcitx5-lotus"
sudo apt-get update
sudo apt-get install -y fcitx5-lotus

say "Enabling $LOTUS_SERVICE"
sudo systemctl enable --now "$LOTUS_SERVICE" ||
    { sudo systemd-sysusers && sudo systemctl enable --now "$LOTUS_SERVICE"; }
# The lotus server creates its virtual input device through uinput.
sudo modprobe uinput

# --- 3. Autostart and configuration tooling ----------------------------------

say "Installing gnome-tweaks and the fcitx5 configuration tool"
sudo apt-get install -y gnome-tweaks fcitx5-config-qt

say "Done. Remaining manual steps:"
echo "  1. Run scripts/disable-ibus.sh to stop the old IBus and write the"
echo "     input-method variables to ~/.bash_profile"
echo "  2. GNOME Tweaks -> Startup Applications -> Add -> Fcitx 5"
echo "  3. Run fcitx5-configtool, move lotus to the active engines column, press Apply"
echo "  4. Log out and log back in so ~/.bash_profile takes effect"
