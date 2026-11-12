# linux

Idempotent shell scripts for setting up a fresh Ubuntu (24.04 / 26.04) desktop — dev toolchain, AI CLIs, Vietnamese input, and everyday apps in one unattended run.

## Quick start

```bash
bash scripts/setup-full.sh
```

Run as a normal user with sudo (login password). Every script is idempotent — re-running any step is safe.

## What it sets up

1. **Prerequisites** — apt update/upgrade, universe repo, curl/git/flatpak, `libfuse2t64`
2. **Dev toolchain** — uv, zoxide, tailscale, nvm, Python 3, Node.js/npm, ripgrep, fd, jq, zsh
3. **AI CLIs** — Hermes, Codex, Claude Code, Zed
4. **Fonts + Vietnamese input** — fcitx5-lotus, ms core fonts, IBus disabled
5. **Zalo** — version-pinned AppImage via Gear Lever
6. **Verification** — `verify.sh` gives a machine-checkable pass/fail signal

## Optional scripts

`install-asyar.sh`, `install-gradia.sh`, `install-claude-desktop.sh` (any time after init), plus `port-env-vars.sh` for the zsh switch.

## Docs

See [scripts/README.md](scripts/README.md) for the full execution order, reasoning, and caveats.
