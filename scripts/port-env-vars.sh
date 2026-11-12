#!/usr/bin/env bash
# Ports the fcitx5 input-method environment variables to ~/.zprofile.
#
# The fresh-Ubuntu setup is bash-only: disable-ibus.sh writes the six
# exports to ~/.bash_profile only. After switching your login shell to zsh
# (chsh -s $(which zsh)), a login shell no longer reads that file and
# Vietnamese input silently stops working in GTK/Qt apps — run this script
# to port the variables.
#
# Idempotent: lines already present in ~/.zprofile are not duplicated.
# No sudo, no prompts.
set -euo pipefail

PROFILE="$HOME/.zprofile"

say() { printf '\n==> %s\n' "$*"; }

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

say "Done. Log out and back in so $PROFILE takes effect."
