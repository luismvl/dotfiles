# Ubuntu Dotfiles

Personal dotfiles for Ubuntu, WSL, Ubuntu desktop, and Linux dev servers.

This repo is managed with [chezmoi](https://www.chezmoi.io/). There is no custom
wrapper and no install modes to remember.

## Daily Commands

```bash
chezmoi diff
chezmoi apply
chezmoi update
chezmoi cd
```

What they mean:

- `chezmoi diff`: preview what would change.
- `chezmoi apply`: apply dotfiles and run bootstrap scripts when needed.
- `chezmoi update`: pull the repo and apply it.
- `chezmoi cd`: open the chezmoi source repo.

## First Setup

If chezmoi is not installed yet:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
```

If the repo is already cloned:

```bash
cd ~/dotfiles
mkdir -p ~/.config/chezmoi
printf 'sourceDir = "%s"\n' "$PWD" > ~/.config/chezmoi/chezmoi.toml
chezmoi diff
chezmoi apply
```

On a new machine from a remote repo:

```bash
chezmoi init <repo-url>
chezmoi diff
chezmoi apply
```

Use `chezmoi init --apply <repo-url>` only when you already trust the repo and
are comfortable applying the bootstrap scripts immediately.

## What Gets Managed

- `zsh` config and plugins
- `tmux`
- `starship`
- `eza`
- `nvim` with LazyVim
- `alacritty` config
- Ubuntu package bootstrap for common web-dev, Python, Go, and Java tools
- Caskaydia Nerd Font on desktop Ubuntu only

Codex config is intentionally not managed. Keep `~/.codex/config.toml`
machine-local.

## Local-Only Files

These are intentionally left out of the repo:

- `~/.zshrc.local`
- `~/.tmux.conf.local`
- `~/.config/nvim/lua/config/local.lua`
- `~/.config/alacritty/local-font.toml`
- `~/.codex/config.toml`

## Environment Behavior

There are no `server`, `desktop`, or `minimal` flags anymore.

Chezmoi scripts detect what they can:

- WSL and headless servers skip Alacritty/font desktop bootstrap.
- WSL installs Caskaydia Nerd Font into Windows user fonts, applies a matching
  Windows Terminal theme, and writes a Windows Alacritty config for future use.
- Ubuntu desktop installs Alacritty and Caskaydia Nerd Font.
- `zsh` is set as the login shell once if needed.
- Bootstrap scripts are idempotent and re-run only when their script content
  changes.

After the first apply, restart the terminal. In WSL, run this from PowerShell if
the login shell changed:

```powershell
wsl --shutdown
```

## Tooling Notes

See [docs/tools.md](docs/tools.md) for what gets installed and why.
