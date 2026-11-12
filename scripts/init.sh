#!/usr/bin/env bash
# Prerequisite phase for scripts/dev.sh and scripts/linux-ai.sh on a fresh Ubuntu
# install: download tools, source control, and the universe repo they assume.
# Idempotent; safe to re-run. Run as a normal user (the other scripts call sudo).
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

say() { printf '\n==> %s\n' "$*"; }

# Fail fast when an agent runs us without a tty and without cached sudo
# credentials, instead of hanging on a password prompt.
if [ ! -t 0 ] && ! sudo -n true 2>/dev/null; then
    echo "ERROR: non-interactive shell without cached sudo credentials; run 'sudo -v' in your terminal first, then retry" >&2
    exit 1
fi

# Prompt for the login password once up front; caches sudo for the later calls
# in this script and in dev.sh (default timeout ~15 min).
sudo -v || { echo "ERROR: sudo is required" >&2; exit 1; }

say "Updating and upgrading base system"
sudo apt-get update
sudo apt-get upgrade -y

say "Installing foundational tools"
sudo apt-get install -y ca-certificates curl git gnupg wget unzip xz-utils software-properties-common flatpak

say "Enabling universe repository (fd-find and friends in dev.sh)"
sudo add-apt-repository -y universe
sudo apt-get update

say "Installing libfuse2t64 (AppImage runtime for install-zalo.sh)"
sudo apt-get install -y libfuse2t64
