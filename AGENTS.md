# Dotfiles Agent Policy

## Config Pattern (Mandatory)
For any config that can contain secrets or machine-specific values, use this pattern:

1. **Tracked base file** in repo (`*.base.*`) with placeholders/defaults.
2. **Untracked local file** (`*.local.*`) per machine with secrets/overrides.
3. **Generated final file** at install/apply time.

Never symlink a tracked file directly to a live config when that live config may be edited with secrets.

## Existing Local-Override Pattern
- Zsh: `~/.zshrc.local`
- tmux: `~/.tmux.conf.local`
- Neovim: `~/.config/nvim/lua/config/local.lua`
- Alacritty font: `~/.config/alacritty/local-font.toml` (generated)
- Codex: `codex/config.base.toml` + `codex/config.local.env` -> `~/.codex/config.toml`
- Codex skills: `codex/skills.manifest` + `scripts/bootstrap_codex.sh` -> `~/.codex/skills/*`

## When Adding New Dotfiles
Before linking or generating a config, classify it:
- **Portable/static**: safe to symlink directly.
- **Machine-specific or secret-bearing**: must use base+local+generated pattern.

## Server Profile
Use `./install.sh --server` for dev servers (no desktop UX assumptions):
- Skips desktop-only terminal/font setup.
- Keeps shell/tmux/nvim/codex setup.
