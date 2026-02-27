# Ubuntu Dotfiles

Small, practical dotfiles repo to replicate this shell/tooling setup on Ubuntu.

## What this configures

- Zsh behavior, keybindings, aliases, and helper function (`zshrc`)
- Starship one-line subdued prompt (`starship.toml`)
- eza subdued theme file (`eza/theme.yml`)
- Install script for packages, plugins, and symlinks (`install.sh`)

## File layout

```text
dotfiles/
├── zshrc
├── starship.toml
├── eza/
│   └── theme.yml
├── install.sh
└── README.md
```

## Install

From repo root:

```bash
chmod +x install.sh
./install.sh
```

Dry-run (no changes, no installs):

```bash
./install.sh --dry-run
```

The script will:

- Install Ubuntu packages (when available via `apt`):
  - `zsh`, `git`, `curl`, `fzf`, `ripgrep`, `fd-find`, `bat`, `eza`, `alacritty`
- Install `zoxide` (official install script)
- Install `starship` (official install script)
- Set Alacritty as default terminal:
  - Ubuntu `25.04+`: writes `Alacritty.desktop` first in `~/.config/ubuntu-xdg-terminals.list`
  - Older Ubuntu: uses `update-alternatives` for `x-terminal-emulator`
- Clone Zsh plugins (if missing):
  - `~/.zsh/plugins/zsh-autosuggestions`
  - `~/.zsh/plugins/zsh-history-substring-search`
  - `~/.zsh/plugins/zsh-syntax-highlighting`
- Create directories:
  - `~/.config`
  - `~/.config/eza`
  - `~/.zsh/plugins`
- Symlink files:
  - `zshrc` -> `~/.zshrc`
  - `starship.toml` -> `~/.config/starship.toml`
  - `eza/theme.yml` -> `~/.config/eza/theme.yml`

## Existing file safety policy

If a target file already exists, `install.sh` moves it to a timestamped backup:

- `~/.zshrc.bak.YYYYMMDD-HHMMSS`
- `~/.config/starship.toml.bak.YYYYMMDD-HHMMSS`
- `~/.config/eza/theme.yml.bak.YYYYMMDD-HHMMSS`

Then it creates the new symlink.

## Ubuntu caveats

- Ubuntu package names used in this setup:
  - `bat` command is typically `batcat`
  - `fd` command is typically `fdfind`
- `eza` availability can differ by Ubuntu release/repositories.
- `alacritty` availability can differ by Ubuntu release/repositories.
- eza theme-file support can vary by eza version/build:
  - This repo still installs `~/.config/eza/theme.yml`.
  - If your eza build does not load theme files, use an `EZA_COLORS` fallback locally and keep `theme.yml` as source of truth.

## Plugin paths

Plugins are expected at:

- `~/.zsh/plugins/zsh-autosuggestions`
- `~/.zsh/plugins/zsh-history-substring-search`
- `~/.zsh/plugins/zsh-syntax-highlighting`

`zsh-syntax-highlighting` is loaded last in `zshrc`.

## Refresh shell

```bash
exec zsh
```

## Uninstall / remove symlinks

```bash
rm -f ~/.zshrc ~/.config/starship.toml ~/.config/eza/theme.yml
```

Optionally restore from backups created by `install.sh`.
