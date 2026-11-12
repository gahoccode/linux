# Fresh-Ubuntu setup — flow, order, and reasons

One command, from repo root:

```bash
bash scripts/setup-full.sh
```

Run as a normal user with sudo (login password). `init.sh` prompts for the password once and caches it (~15 min); running the steps back-to-back keeps the cache alive. Every script is idempotent — re-running any step is safe. The run is fully unattended: no script prompts, the office setup is lotus-only (fonts + install), and `disable-ibus.sh` writes the input-method environment variables to `~/.bash_profile`.

Agent runs: prime `sudo -v` in a real terminal first — `init.sh`, `dev.sh`, and `linux-office-setup.sh` fail fast with instructions when run without a tty and cached credentials, instead of hanging. The full sequence can exceed agent command timeouts (~10 min), so run it stepwise or in the background; `verify.sh` at the end provides the machine-checkable pass/fail signal.

After cloning: `cd scripts && bash chmod-scripts.sh` once makes every `.sh` in the current directory directly executable (`./setup-full.sh` etc.); the `bash scripts/...` invocations keep working regardless.

## Execution order and why

1. **init.sh — prerequisites.** apt update/upgrade, then `ca-certificates curl git gnupg wget unzip xz-utils software-properties-common flatpak`; enables **universe**; installs `libfuse2t64`. First because `dev.sh:3` and all of `linux-ai.sh` are `curl | sh` pipes, `fd-find` and `flatpak` live in universe, `git` is needed by nvm/Hermes, and Ubuntu (24.04 and 26.04 alike) bundles no flatpak.
2. **dev.sh — dev toolchain.** uv/zoxide/tailscale/nvm via curl installers; python3, build tools, `fd-find jq ripgrep zsh nodejs npm …` via apt. Precedes linux-ai.sh because **Hermes expects node/npm** and otherwise downloads its own Node.js `.tar.xz` (hence `xz-utils` in init.sh).
3. **linux-ai.sh — AI CLIs.** Hermes (`--non-interactive`), Codex (`CODEX_NON_INTERACTIVE=true`), Claude Code, Zed. All four installers audited: prompt-free as invoked, user-scope, no sudo.
4. **linux-office-setup.sh — fonts + Vietnamese input.** Needs universe (init.sh — `gnome-tweaks`, `fcitx5-config-qt`) and multiverse for `ttf-mscorefonts-installer` (pre-enabled on stock installs; EULA preseeded). Installs fcitx5-lotus unconditionally — no arguments, no prompts. The old-IBus stop and the environment-variable write (linux-office.md steps 7–8) live in `disable-ibus.sh`, run next.
5. **disable-ibus.sh — old-IBus stop + input-method variables.** Stops the user's `ibus-daemon` so it does not conflict with fcitx5, then appends the six input-method exports to `~/.bash_profile` (idempotent, no sudo).
6. **install-zalo.sh — Zalo.** Gear Lever self-installs from flathub when missing (offline bundle preferred if staged), the pinned Zalo AppImage is wget-fetched and integrated. `libfuse2t64` from step 1 makes the AppImage launch.
7. **verify.sh — verification.** Read-only pass/fail over steps 1–3 and 6 plus the optional Asyar; skips the office setup and the Claude Desktop `.deb` by design. Exits non-zero on any FAIL, so agents get a trustworthy end-of-run signal.

Steps 4–6 depend only on step 1; sequenced last for a deterministic run.

## Optional scripts (any time after init.sh)

- **install-asyar.sh** — ready as-is (curl only); `--force` upgrades.
- **install-gradia.sh** — snap path works on Desktop; on minimal images its flatpak fallback needs a system flathub remote, which nothing here configures.
- **install-claude-desktop.sh** — known broken (see caveats); use [office-productivity/claude-desktop-linux.md](../office-productivity/claude-desktop-linux.md) until fixed.
- **port-env-vars.sh** — run after `chsh -s $(which zsh)`; ports the six fcitx5 variables to `~/.zprofile`, idempotently.
- **chmod-scripts.sh** — generic helper: `chmod +x` every `.sh` in the current directory (no-op message when there are none).

## Post-setup

- New shell / re-login for the uv, zoxide, nvm, and fcitx5 rc edits.
- `chsh -s $(which zsh)` to make zsh the login shell (dev.sh installs but does not switch); then run `bash scripts/port-env-vars.sh`, or Vietnamese input stops working in GTK/Qt apps.
- nvm manages no Node by itself; system `nodejs`/`npm` from dev.sh already work.

## Caveats

| Area | Note |
|---|---|
| `install-claude-desktop.sh` | Downloads the `.deb` to the working directory but installs `./Downloads/claude-desktop_*.deb` — fails from every directory; excluded from the runner and from `verify.sh`. |
| multiverse | `ttf-mscorefonts-installer` requires multiverse; stock installs pre-enable it, stripped images need `add-apt-repository -y multiverse`. |
| zsh switch | The setup is bash-only; the fcitx5 variables written by `disable-ibus.sh` live in `~/.bash_profile`. After switching to zsh, run `scripts/port-env-vars.sh` or Vietnamese input silently stops working. |
| Zalo pinning | Version-pinned `ZALO_APPIMAGE`/`ZALO_URL`; no checksum verification — the GitHub release URL is the trust anchor. |
| Remote installers | The eight curl-piped installers were audited 2026-09-13; upstream changes may invalidate those findings. |
| Hermes flags | `--non-interactive` skips optional system packages; already covered by dev.sh's apt line. |
| verify scope | `verify.sh` cannot confirm the office setup (engine activation, autostart, and re-login are manual GUI steps) or the Claude Desktop `.deb`; Asyar is SKIP, not FAIL, because it is not part of the runner. |
| sudo cache | ~15-minute timeout; long sequences re-prompt for the password. Non-interactive shells without cached credentials fail fast with instructions instead of hanging. |
