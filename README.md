# Ubuntu Dotfiles

Small, practical dotfiles repo to replicate this shell/tooling setup on Ubuntu.

## What this configures

- Zsh behavior, keybindings, aliases, and helper function (`zshrc`)
- Starship one-line subdued prompt (`starship.toml`)
- eza subdued theme file (`eza/theme.yml`)
- Alacritty terminal config (`alacritty.toml`)
- tmux dev config (`tmux.conf`)
- LazyVim Neovim config for web dev (`nvim/`)
- Install script for packages, plugins, and symlinks (`install.sh`)

## File layout

```text
dotfiles/
├── zshrc
├── starship.toml
├── alacritty.toml
├── tmux.conf
├── nvim/
│   ├── init.lua
│   └── lua/
│       ├── config/
│       │   ├── lazy.lua
│       │   └── options.lua
│       └── plugins/
│           └── webdev.lua
├── eza/
│   └── theme.yml
├── install.sh
├── scripts/
│   └── install_lib.sh
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
  - `zsh`, `git`, `curl`, `neovim`, `build-essential`, `unzip`, `xclip`, `tree-sitter-cli`, `fzf`, `ripgrep`, `fd-find`, `bat`, `eza`, `alacritty`, `tmux`
- Install `zoxide` (official install script)
- Install `starship` (official install script)
- Ensure Neovim is compatible with LazyVim:
  - Requires `nvim >= 0.11.2`
  - If missing or too old, installs latest Neovim tarball to `~/.local` and links `~/.local/bin/nvim`
- Install Caskaydia Nerd Font from Nerd Fonts latest release tarball into:
  - `~/.local/share/fonts/CaskaydiaCoveNerdFont` (always reinstall)
- Detect installed Caskaydia Nerd Font family and generate:
  - `~/.config/alacritty/local-font.toml`
- Set Alacritty as default terminal:
  - Ubuntu `25.04+`: writes `Alacritty.desktop` first in `~/.config/ubuntu-xdg-terminals.list`
  - Older Ubuntu: uses `update-alternatives` for `x-terminal-emulator`
- Clone Zsh plugins (if missing):
  - `~/.zsh/plugins/zsh-autosuggestions`
  - `~/.zsh/plugins/zsh-history-substring-search`
  - `~/.zsh/plugins/fzf-tab`
  - `~/.zsh/plugins/zsh-syntax-highlighting`
- Create directories:
  - `~/.config`
  - `~/.config/eza`
  - `~/.zsh/plugins`
- Symlink files:
  - `zshrc` -> `~/.zshrc`
  - `starship.toml` -> `~/.config/starship.toml`
  - `eza/theme.yml` -> `~/.config/eza/theme.yml`
  - `alacritty.toml` -> `~/.config/alacritty/alacritty.toml`
  - `tmux.conf` -> `~/.tmux.conf`
  - `nvim/` -> `~/.config/nvim`

## Existing file safety policy

If a target file already exists, `install.sh` moves it to a timestamped backup:

- `~/.zshrc.bak.YYYYMMDD-HHMMSS`
- `~/.config/starship.toml.bak.YYYYMMDD-HHMMSS`
- `~/.config/eza/theme.yml.bak.YYYYMMDD-HHMMSS`
- `~/.config/alacritty/alacritty.toml.bak.YYYYMMDD-HHMMSS`
- `~/.tmux.conf.bak.YYYYMMDD-HHMMSS`
- `~/.config/nvim.bak.YYYYMMDD-HHMMSS`

Then it creates the new symlink.

## Ubuntu caveats

- Ubuntu package names used in this setup:
  - `bat` command is typically `batcat`
  - `fd` command is typically `fdfind`
- `eza` availability can differ by Ubuntu release/repositories.
- `alacritty` availability can differ by Ubuntu release/repositories.
- `tree-sitter-cli` availability can differ by Ubuntu release/repositories.
- Nerd Fonts release/API availability can affect automatic font install.
- If Ubuntu `neovim` is below `0.11.2`, installer uses Neovim latest tarball from GitHub.
- eza theme-file support can vary by eza version/build:
  - This repo still installs `~/.config/eza/theme.yml`.
  - If your eza build does not load theme files, use an `EZA_COLORS` fallback locally and keep `theme.yml` as source of truth.
- If Nerd Font install fails, installer warns and continues (it does not abort).

## Plugin paths

Plugins are expected at:

- `~/.zsh/plugins/zsh-autosuggestions`
- `~/.zsh/plugins/zsh-history-substring-search`
- `~/.zsh/plugins/fzf-tab`
- `~/.zsh/plugins/zsh-syntax-highlighting`

`zsh-syntax-highlighting` is loaded last in `zshrc`.

## Refresh shell

```bash
exec zsh
```

Reload tmux config:

```bash
tmux source-file ~/.tmux.conf
```

tmux persistence (resurrect + continuum):

- One-time after opening tmux: `prefix + I` (installs tmux plugins via TPM)
- Manual save session: `prefix + Ctrl-s`
- Manual restore session: `prefix + Ctrl-r`
- Auto-save every 15 minutes and auto-restore on tmux start are enabled.

LazyVim first run:

```bash
nvim
```

On first launch, LazyVim/lazy.nvim will install plugins automatically.
Then run `:LazyHealth` and `:LazyExtras` to explore/add more modules as you learn.

Included web-dev extras:

- TypeScript
- Tailwind CSS
- JSON
- Markdown
- ESLint
- Prettier

## Uninstall / remove symlinks

```bash
rm -f ~/.zshrc ~/.config/starship.toml ~/.config/eza/theme.yml ~/.config/alacritty/alacritty.toml ~/.config/alacritty/local-font.toml ~/.tmux.conf ~/.config/nvim
```

Optionally restore from backups created by `install.sh`.

## Font troubleshooting

```bash
fc-list | rg -i "(caskaydia|cascadia).*nerd"
fc-cache -f
alacritty --version
```
