# Ubuntu Dotfiles

Small, practical dotfiles repo to replicate this shell/tooling setup on Ubuntu.

## What this configures

- Zsh behavior, keybindings, aliases, and helper function (`zshrc`)
- Starship one-line subdued prompt (`starship.toml`)
- eza subdued theme file (`eza/theme.yml`)
- Alacritty terminal config (`alacritty.toml`)
- tmux dev config (`tmux.conf`)
- LazyVim Neovim config for web dev (`nvim/`)
- Codex global config (rendered from `codex/config.base.toml`)
- Modular install scripts for system bootstrap, config apply, and optional personal tools

## File layout

```text
dotfiles/
├── zshrc
├── starship.toml
├── alacritty.toml
├── tmux.conf
├── nvim/
│   ├── init.lua
│   ├── lazyvim.json
│   └── lua/
│       ├── config/
│       │   ├── lazy.lua
│       │   ├── local.example.lua
│       │   └── options.lua
│       └── plugins/
│           ├── theme.lua
│           └── webdev.lua
├── eza/
│   └── theme.yml
├── codex/
│   ├── config.base.toml
│   ├── config.local.example.env
│   └── skills.manifest.example
├── install.sh
├── scripts/
│   ├── install_lib.sh
│   ├── apply_dotfiles.sh
│   ├── bootstrap_system.sh
│   └── bootstrap_codex.sh
└── README.md
```

## Install

From repo root:

```bash
chmod +x install.sh
./install.sh
```

Server/dev-only profile (no desktop assumptions):

```bash
./install.sh --server
```

Minimal/apply-only mode (no apt, no downloads, no plugin/tool bootstrap):

```bash
./install.sh --minimal
```

Optional personal tools bootstrap in same run:

```bash
./install.sh --with-personal-tools
```

Dry-run (no changes, no installs):

```bash
./install.sh --dry-run
```

Dry-run with server profile:

```bash
./install.sh --server --dry-run
```

Dry-run with minimal mode:

```bash
./install.sh --minimal --dry-run
```

### Mode Matrix

| Command | System bootstrap (`bootstrap_system.sh`) | Apply config (`apply_dotfiles.sh`) | Personal tools (`bootstrap_codex.sh`) |
|---|---|---|---|
| `./install.sh` | Yes (`desktop`) | Yes | No |
| `./install.sh --server` | Yes (`server`) | Yes | No |
| `./install.sh --minimal` | No | Yes | No |
| `./install.sh --with-personal-tools` | Yes (`desktop`) | Yes | Yes |
| `./install.sh --server --with-personal-tools` | Yes (`server`) | Yes | Yes |
| `./install.sh --minimal --with-personal-tools` | No | Yes | Yes |

Codex bootstrap (CLI + skills):

```bash
# one-time: create local skill manifest
cp codex/skills.manifest.example codex/skills.manifest

# inspect actions only
./scripts/bootstrap_codex.sh --dry-run

# apply
./scripts/bootstrap_codex.sh
```

`install.sh` now orchestrates three modules:

- `scripts/bootstrap_system.sh`:
  - apt packages, zoxide/starship/neovim
  - desktop-only terminal/font setup when profile is desktop
  - zsh/tmux plugin cloning
- `scripts/apply_dotfiles.sh`:
  - symlinks for zsh/starship/eza/tmux/nvim (+ alacritty on desktop)
  - renders `~/.codex/config.toml` from `codex/config.base.toml` + optional `codex/config.local.env`
  - ensures managed `~/.zshrc` include block
- `scripts/bootstrap_codex.sh` (optional):
  - Codex CLI bootstrap
  - skills sync via `codex/skills.manifest`

Run modules directly if needed:

```bash
./scripts/bootstrap_system.sh --profile server
./scripts/apply_dotfiles.sh --profile server
./scripts/bootstrap_codex.sh --dry-run
```

## Existing file safety policy

If a target file already exists, `install.sh` moves it to a timestamped backup:

- `~/.config/dotfiles/zshrc.bak.YYYYMMDD-HHMMSS`
- `~/.config/starship.toml.bak.YYYYMMDD-HHMMSS`
- `~/.config/eza/theme.yml.bak.YYYYMMDD-HHMMSS`
- `~/.config/alacritty/alacritty.toml.bak.YYYYMMDD-HHMMSS`
- `~/.tmux.conf.bak.YYYYMMDD-HHMMSS`
- `~/.config/nvim.bak.YYYYMMDD-HHMMSS`
- `~/.codex/config.toml.bak.YYYYMMDD-HHMMSS`

Then it creates the new symlink.

For `~/.zshrc` specifically:

- If `~/.zshrc` is a symlink, installer backs it up and creates a regular `~/.zshrc` with the managed source block.
- If `~/.zshrc` exists as a file, installer updates or appends the managed source block (does not replace unrelated lines).

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

## Machine-local overrides (recommended)

For machine-specific config that should not be committed to dotfiles:

- Zsh: `~/.zshrc.local` (auto-sourced by `~/.config/dotfiles/zshrc`)
- tmux: `~/.tmux.conf.local` (auto-sourced by `~/.tmux.conf`)
- Neovim: `~/.config/nvim/lua/config/local.lua` (optional `pcall(require, "config.local")`)
- Codex: `dotfiles/codex/config.local.env` (do not commit; see `codex/config.local.example.env`)

Codex notes:

- `codex/config.base.toml` is the tracked global baseline (rules, MCP, behavior).
- Put machine-specific or secret values in untracked `codex/config.local.env`.
- `install.sh` renders the final `~/.codex/config.toml` automatically.
- Do not commit `~/.codex/skills` directories directly. Prefer committing:
  - `[[skills.config]]` entries in `codex/config.base.toml`
  - skill source repos or installer scripts if you want reproducible installs.
- Skills install/sync is handled by `scripts/bootstrap_codex.sh` + `codex/skills.manifest`:
  - `symlink` mode for local skill folders (fastest for dev machines)
  - `clone` mode for Git skill repos (best for server reproducibility)

Suggested local stacks completion example in `~/.zshrc.local`:

```zsh
if command -v stacks >/dev/null 2>&1; then
  eval "$(stacks completion zsh)"
fi
```

Reload tmux config:

```bash
tmux source-file ~/.tmux.conf
```

tmux plugins:

- One-time after opening tmux: `prefix + I` (installs tmux plugins via TPM)

LazyVim first run:

```bash
nvim
```

On first launch, LazyVim/lazy.nvim will install plugins automatically.
Then run `:checkhealth lazy`, `:checkhealth lazyvim`, and `:LazyExtras` to explore/add more modules as you learn.

Included web-dev extras:

- TypeScript
- Tailwind CSS
- JSON
- Markdown
- ESLint
- Prettier

## Uninstall / remove symlinks

```bash
rm -f ~/.config/dotfiles/zshrc ~/.config/starship.toml ~/.config/eza/theme.yml ~/.config/alacritty/alacritty.toml ~/.config/alacritty/local-font.toml ~/.tmux.conf ~/.config/nvim
```

Optional cleanup if you want to remove the managed include from `~/.zshrc` too:

```bash
sed -i '/^# >>> dotfiles-zsh >>>$/,/^# <<< dotfiles-zsh <<</d' ~/.zshrc
```

Optionally restore from backups created by `install.sh`.

## Font troubleshooting

```bash
fc-list | rg -i "(caskaydia|cascadia).*nerd"
fc-cache -f
alacritty --version
```
