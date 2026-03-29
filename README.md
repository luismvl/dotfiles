# My Ubuntu Dotfiles

This repo recreates my usual Ubuntu setup.

It is not meant to be a generic dotfiles framework. It just installs the shell, editor, tmux, terminal, and Codex setup I want on a new machine.

## What it covers

- `zsh` + plugins
- `starship`
- `eza`
- `tmux`
- `nvim` (LazyVim-based)
- `codex` config
- `alacritty` + font setup on desktop machines
- optional Codex CLI + skills bootstrap

## Commands I actually need

```bash
./install.sh
./install.sh server
./install.sh minimal
./install.sh tools
./install.sh server tools
./install.sh dry-run
```

What those mean:

- default: full desktop/laptop setup
- `server`: skip desktop-only terminal/font work
- `minimal`: only apply configs; no apt installs or downloads
- `tools`: also run the optional Codex bootstrap step
- `dry-run`: preview only

If I want flags instead of bare words, these are the readable ones:

- `--server`
- `--minimal`
- `--tools`
- `--dry-run`

You can combine them:

```bash
./install.sh server tools dry-run
./install.sh --server --tools --dry-run
```

Old flags still work if I already have muscle memory for them:

- `--apply-only`
- `--personal-tools`
- `--with-personal-tools`

## What the installer does

`./install.sh` is just a wrapper around three scripts:

- `scripts/bootstrap_system.sh`: packages, zoxide, starship, neovim, plugins, and desktop extras
- `scripts/apply_dotfiles.sh`: symlinks + generated config files
- `scripts/bootstrap_codex.sh`: optional Codex CLI + skills sync

If I need to debug one piece, I can run the scripts directly.

## Local-only files

Anything machine-specific or secret-bearing should use the base + local + generated pattern.

Current local overrides:

- `~/.zshrc.local`
- `~/.tmux.conf.local`
- `~/.config/nvim/lua/config/local.lua`
- `codex/config.local.env` -> rendered into `~/.codex/config.toml`

Useful one-time copies:

```bash
cp codex/config.local.example.env codex/config.local.env
cp codex/skills.manifest.example codex/skills.manifest
```

## Codex tools

If I run `./install.sh tools`, it will:

- install the Codex CLI if it is missing
- sync skills from `codex/skills.manifest`

I can also run that step directly:

```bash
./scripts/bootstrap_codex.sh
./scripts/bootstrap_codex.sh --dry-run
```

## Safety

Existing files are backed up before being replaced.

`~/.zshrc` stays a normal file. The installer only manages a small include block that sources the repo-managed zsh config.

## After install

```bash
exec zsh
tmux source-file ~/.tmux.conf
nvim
```

Notes:

- first tmux run: `prefix + I`
- first Neovim run installs LazyVim plugins automatically
