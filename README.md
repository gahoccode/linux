# linux

Idempotent shell scripts for setting up a fresh Ubuntu (24.04 / 26.04) desktop — a core unattended run (dev toolchain, AI CLIs, Zalo, IBus off) plus an office track (fonts, Vietnamese input, zsh migration) as a second command.

## Quick start

```bash
bash scripts/setup-full.sh   # core: prerequisites, dev toolchain, AI CLIs, Zalo, IBus off
bash scripts/office-suite.sh # office: fonts + fcitx5-lotus, zsh switch + var port
```

Run as a normal user with sudo (login password); each runner is unattended apart from the sudo prompt. `office-suite.sh` assumes `setup-full.sh` ran (it needs init.sh's flatpak and dev.sh's zsh). Every script is idempotent — re-running any step is safe.

## What setup-full.sh sets up

1. **Prerequisites** — apt update/upgrade, universe repo, curl/git/flatpak, `libfuse2t64`
2. **Dev toolchain** — uv, zoxide, tailscale, nvm, Python 3, Node.js/npm, ripgrep, fd, jq, zsh
3. **AI CLIs** — Hermes, Codex, Claude Code, Zed
4. **Input-method base** — IBus disabled, fcitx5 environment variables in `~/.bash_profile`
5. **Zalo** — version-pinned AppImage via Gear Lever
6. **Verification** — `verify.sh` gives a machine-checkable pass/fail signal

### office-suite.sh adds

- **Fonts + Vietnamese input** — Microsoft core fonts, fcitx5-lotus engine and server
- **zsh migration** — login shell switched to zsh, fcitx5 variables ported to `~/.zprofile`
- Ends with manual steps: log out and back in, add Fcitx 5 to GNOME Tweaks startup applications, activate the lotus engine in fcitx5-configtool

## Optional scripts

`install-asyar.sh`, `install-gradia.sh`, `claude-desktop.sh`, `linux-office-setup.sh` (standalone, without the rest of the office suite), plus `port-env-vars.sh` (zsh switch + var port) if you ran only `setup-full.sh`.

## Docs

See [scripts/README.md](scripts/README.md) for the full execution order, reasoning, and caveats.
