#!/usr/bin/env bash
#
# Completely disables the old IBus input method and declares the fcitx5
# input-method environment variables in ~/.bash_profile, so the old engine
# does not conflict with fcitx5-lotus: steps 7-8 of
# office-productivity/linux-office.md. Split out of linux-office-setup.sh,
# which now only installs the Microsoft core fonts and fcitx5-lotus.
#
# Usage:
#   ./disable-ibus.sh
#
# Stops the ibus-daemon of the current user and appends the six exports to
# ~/.bash_profile (port them with port-env-vars.sh if you ever switch your
# login shell to zsh). Safe to re-run: the daemon stop is a no-op when
# nothing is running, and each export is only written once.
# No sudo, no prompts.
#
# Sources:
#   - Video guide (lotus): https://www.youtube.com/watch?v=WBd8iy-bePA
#   - Fcitx 5 environment variables: https://fcitx-im.org/wiki/Setup_Fcitx_5#Environment_variables
#

set -euo pipefail

say() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

if [ "$(id -u)" -eq 0 ]; then
    die "Run as a normal user, not with sudo; this stops your own ibus-daemon and edits your own ~/.bash_profile."
fi

PROFILE="$HOME/.bash_profile"

# --- 1. Stop the old IBus input method ----------------------------------------

say "Stopping IBus to avoid conflicts with fcitx5"
killall ibus-daemon 2>/dev/null || ibus exit 2>/dev/null || true

# --- 2. Environment variables (idempotent, bash) ------------------------------

say "Writing input-method environment variables to $PROFILE"
touch "$PROFILE"
add_env() {
    grep -qxF "export $1" "$PROFILE" || echo "export $1" >>"$PROFILE"
}
add_env 'GTK_IM_MODULE=fcitx'
add_env 'QT_IM_MODULE=fcitx'
add_env 'XMODIFIERS=@im=fcitx'
add_env 'SDL_IM_MODULE=fcitx'
add_env 'GLFW_IM_MODULE=ibus'
add_env 'QT_IM_MODULES="wayland;fcitx"'

say "Done. Log out and back in so $PROFILE takes effect. If IBus autostarts again after re-login, disable or remove it; it conflicts with fcitx5."
