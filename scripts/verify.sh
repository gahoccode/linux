#!/usr/bin/env bash
# Read-only post-setup verification for the fresh-Ubuntu setup. Prints one
# PASS/FAIL line per component and exits non-zero if anything failed, so
# agents and humans get a machine-checkable signal that setup-full.sh
# actually installed everything.
#
# Skipped by design:
#   - Claude Desktop .deb (install-claude-desktop.sh is broken and excluded
#     from the runner)
#   - office setup (fcitx5-lotus packages, service, and the env vars
#     written by disable-ibus.sh): its real acceptance is the manual GUI
#     steps printed by linux-office-setup.sh and disable-ibus.sh, which
#     no machine check can confirm
#   - Asyar is optional (install-asyar.sh is not part of the runner), so it
#     is reported as SKIP when absent, not FAIL
#
# Checks use canonical install paths, not just command -v: right after
# setup, ~/.local/bin is not on PATH until the next login.
set -euo pipefail

PASS=0
FAIL=0
SKIP=0

ok() { printf 'PASS  %s\n' "$1"; PASS=$((PASS + 1)); }
no() { printf 'FAIL  %s\n' "$1"; FAIL=$((FAIL + 1)); }
skip() { printf 'SKIP  %s\n' "$1"; SKIP=$((SKIP + 1)); }

# check <label> <command...>: PASS when the command succeeds
check() {
    local label="$1"
    shift
    if "$@" >/dev/null 2>&1; then ok "$label"; else no "$label"; fi
}

# check_bin <label> <name>: PASS when found on PATH or in ~/.local/bin
check_bin() {
    local label="$1" name="$2"
    if command -v "$name" >/dev/null 2>&1 || [ -x "$HOME/.local/bin/$name" ]; then
        ok "$label"
    else
        no "$label"
    fi
}

# --- Prerequisites (init.sh) ---------------------------------------------------

check "curl (init.sh)" command -v curl
check "git (init.sh)" command -v git
check "flatpak (init.sh)" command -v flatpak
check "libfuse2t64 (init.sh)" dpkg -s libfuse2t64

# --- Dev toolchain (dev.sh) ----------------------------------------------------

check_bin "uv (dev.sh)" uv
check_bin "zoxide (dev.sh)" zoxide
check_bin "tailscale (dev.sh)" tailscale
check "python3 (dev.sh)" command -v python3
check "pip3 (dev.sh)" command -v pip3
check "nvm (dev.sh)" test -s "$HOME/.nvm/nvm.sh"
check "node (dev.sh)" bash -c 'command -v node || command -v nodejs'
check "npm (dev.sh)" command -v npm
check "cmake (dev.sh)" command -v cmake
check "fd-find (dev.sh)" command -v fdfind
check "jq (dev.sh)" command -v jq
check "ripgrep (dev.sh)" command -v rg
check "zsh (dev.sh)" command -v zsh
check "tmux (dev.sh)" command -v tmux
check "iperf3 (dev.sh)" command -v iperf3
check "openssh-server (dev.sh)" test -x /usr/sbin/sshd

# --- AI CLIs (linux-ai.sh) -----------------------------------------------------

check_bin "hermes (linux-ai.sh)" hermes
check_bin "codex (linux-ai.sh)" codex
check_bin "claude - Claude Code CLI (linux-ai.sh)" claude
check_bin "zed (linux-ai.sh)" zed

# --- Zalo (install-zalo.sh) ----------------------------------------------------

check "Gear Lever flatpak (install-zalo.sh)" bash -c 'flatpak list --user | grep -q it.mijorus.gearlever'
check "Zalo desktop entry (install-zalo.sh)" bash -c "ls \"$HOME/.local/share/applications\" | grep -qi zalo"

# --- Asyar (optional, not part of the runner) ----------------------------------

if command -v asyar >/dev/null 2>&1 || [ -x "$HOME/.local/bin/asyar" ]; then
    ok "asyar (optional, install-asyar.sh)"
else
    skip "asyar (optional, install-asyar.sh) — not installed; run scripts/install-asyar.sh if wanted"
fi

# --- Summary -------------------------------------------------------------------

printf '\n%d passed, %d failed, %d skipped\n' "$PASS" "$FAIL" "$SKIP"

cat <<'EOF'

Manual steps no machine check can confirm (from linux-office-setup.sh / disable-ibus.sh):
  1. GNOME Tweaks -> Startup Applications -> Add -> Fcitx 5
  2. Run fcitx5-configtool, move lotus to the active engines column, press Apply
  3. Log out and log back in so ~/.bash_profile takes effect
EOF

[ "$FAIL" -eq 0 ] || exit 1
