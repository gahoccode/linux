#!/usr/bin/env bash
# Orchestration runner for the office-productivity track, executing the
# four scripts in order: Zalo, fonts + fcitx5-lotus Vietnamese input,
# old-IBus disable, then the zsh migration (login-shell switch + variable
# port). Every step is idempotent, so re-running is safe.
# Assumes init.sh and dev.sh have run (flatpak, wget, libfuse2t64,
# universe repo, zsh). Run as a normal user: linux-office-setup.sh and
# port-env-vars.sh call sudo; keep the steps back-to-back so the password
# is entered once while the sudo cache (~15 min) stays warm.
# Usage: bash scripts/office-suite.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: run as a normal user; the scripts call sudo themselves." >&2
    exit 1
fi

run() {
    printf '\n=== %s ===\n' "$1"
    bash "$SCRIPT_DIR/$1"
}

run zalo.sh
run linux-office-setup.sh

printf '\n=== Reminder ===\n'
printf 'The next step stops the old IBus input method and writes the fcitx5\n'
printf 'variables to ~/.bash_profile. Vietnamese input is unavailable from\n'
printf 'this point until the post-run steps: log out and back in, then\n'
printf 'activate the lotus engine in fcitx5-configtool.\n'

run disable-ibus.sh
run port-env-vars.sh

printf '\nOffice suite complete. Log out and back in: zsh becomes the login shell and ~/.zprofile supplies the fcitx5 variables. Then finish the manual GUI steps printed by linux-office-setup.sh (Tweaks autostart, fcitx5-configtool engine).\n'
