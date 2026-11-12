#!/usr/bin/env bash
set -euo pipefail
echo "Installing Fabric..."
curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/scripts/installer/install.sh | bash
echo "Installing OpenCode..."
curl -fsSL https://opencode.ai/v2/install | bash
echo "Visit https://opencode.ai/download to get the Desktop app"
echo "Installing Codex CLI..."
curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=true sh
echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash
echo "Installing Zed editor..."
curl -f https://zed.dev/install.sh | sh
echo "Installing Hermes..."
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --non-interactive
echo "Installing Herdr Cli..."
curl -fsSL https://herdr.dev/install.sh | sh
echo "Installing Herdr App..."
curl -fsSL https://releases.herdr.dev/app/install.sh | sh
