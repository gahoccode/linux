#!/usr/bin/env bash
# Switches the login shell to zsh and ports the fcitx5 input-method
# environment variables to ~/.zprofile — the complete zsh migration.
#
# The fresh-Ubuntu setup is bash-only: disable-ibus.sh writes the six
# exports to ~/.bash_profile only. This script finishes the migration:
#   1. ports the six exports to ~/.zprofile
#   2. switches the login shell to zsh (sudo chsh; skipped when already zsh)
# Both take effect at the next login. Requires zsh (dev.sh installs it).
# office-suite.sh runs this as its last step; it is also the manual step
# for machines that only ran setup-full.sh.
#
# Idempotent: profile lines are not duplicated and the switch is skipped
# when the login shell is already zsh. Uses sudo (cached from an earlier
# step, or prompts once); in a non-interactive shell without cached
# credentials it fails fast instead of hanging.
set -euo pipefail

say() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

if [ "$(id -u)" -eq 0 ]; then
    die "Run as a normal user; this edits your own ~/.zprofile and switches your own login shell."
fi

# Fail fast when an agent runs us without a tty and without cached sudo
# credentials, instead of hanging on a password prompt.
if [ ! -t 0 ] && ! sudo -n true 2>/dev/null; then
    die "non-interactive shell without cached sudo credentials; run 'sudo -v' in your terminal first, then retry"
fi

ZSH_BIN="$(command -v zsh || true)"
[ -n "$ZSH_BIN" ] || die "zsh not found; run scripts/dev.sh first (it installs zsh)"

PROFILE="$HOME/.zprofile"

# --- 1. Port the environment variables (idempotent) ----------------------------

say "Porting fcitx5 environment variables to $PROFILE"
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

# --- 2. Switch the login shell to zsh (idempotent) ------------------------------

CURRENT_SHELL="$(getent passwd "$(whoami)" | cut -d: -f7)"
if [ "$CURRENT_SHELL" = "$ZSH_BIN" ]; then
    say "Login shell is already zsh; nothing to switch"
else
    say "Switching login shell from $CURRENT_SHELL to zsh"
    sudo chsh -s "$ZSH_BIN" "$(whoami)"
fi

say "Done. Log out and back in: zsh becomes the login shell and $PROFILE supplies the input-method variables."
