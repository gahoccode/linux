#!/usr/bin/env bash
set -euo pipefail

# Fail fast when an agent runs us without a tty and without cached sudo
# credentials, instead of hanging on a password prompt.
if [ ! -t 0 ] && ! sudo -n true 2>/dev/null; then
  echo "ERROR: non-interactive shell without cached sudo credentials; run 'sudo -v' in your terminal first, then retry" >&2
  exit 1
fi

echo "Installing dev dependencies"
sudo apt install build-essential cmake fd-find jq ripgrep zsh openssh-server tmux nodejs npm -y

echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
echo "Install zoxide"
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
echo "Installing python..."
sudo apt install python3 python3-pip -y
echo "Installing tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
echo "Installing Node version manager..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
