# Dotfiles Agent Policy

## Chezmoi Layout

This repo is a chezmoi source repo.

- `.chezmoiroot` points to `home/`.
- Managed home files live under `home/` using chezmoi source names.
- Do not reintroduce `install.sh`, custom install modes, or a wrapper unless the
  user explicitly asks for one.
- Prefer native chezmoi commands: `chezmoi diff`, `chezmoi apply`,
  `chezmoi update`, and `chezmoi cd`.

## Config Pattern

For any config that can contain secrets or machine-specific values, use this
pattern:

1. Tracked portable base/defaults in the repo.
2. Untracked local file per machine with secrets/overrides.
3. Generated final file only when needed.

Never manage a live config that is expected to contain secrets.

## Existing Local-Only Files

- Zsh: `~/.zshrc.local`
- tmux: `~/.tmux.conf.local`
- Neovim: `~/.config/nvim/lua/config/local.lua`
- Alacritty font: `~/.config/alacritty/local-font.toml` (generated)
- Codex: `~/.codex/config.toml` (unmanaged)

Codex setup is intentionally out of scope for this repo.

## Bootstrap Policy

- Use chezmoi `run_once_` or `run_onchange_` scripts for bootstrap work.
- Scripts must be idempotent.
- Scripts must skip gracefully when the platform does not apply.
- WSL and headless servers must skip desktop-only terminal/font work.
- Personal/secret-bearing tools must not be forced.

## When Adding New Dotfiles

Before managing a new config, classify it:

- Portable/static: safe for chezmoi to manage directly.
- Machine-specific or secret-bearing: use local override or generated output.

Update `README.md` and `docs/tools.md` when changing user-facing setup behavior
or installed tooling.
