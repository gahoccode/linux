#!/usr/bin/env bash
# Orchestration runner for the fresh-Ubuntu setup, executing the scripts in
# the order documented in README.md. Every step is idempotent, so re-running
# is safe. Run as a normal user with sudo (login password): init.sh prompts
# for the password once and caches it (~15 min); keep the steps back-to-back.
# Usage: bash scripts/setup-full.sh
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

run init.sh
run dev.sh
run linux-ai.sh

run linux-office-setup.sh
run disable-ibus.sh

run install-zalo.sh
run verify.sh

printf '\nSetup complete. Log out and back in so the fcitx5 variables and PATH additions take effect.\n'
