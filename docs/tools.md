# Tooling Guide

This file explains the tools this dotfiles repo installs or configures. The goal
is to make the setup understandable instead of magic.

## Dotfile Management

- `chezmoi`: applies dotfiles from this repo into `$HOME`. Use `chezmoi diff`
  before `chezmoi apply` to preview changes.

## Shell And Terminal

- `zsh`: default interactive shell.
- `zsh-autosuggestions`: suggests commands from history as you type.
- `zsh-history-substring-search`: lets up/down search history based on the text
  already typed.
- `zsh-syntax-highlighting`: colors valid/invalid shell syntax while typing.
- `fzf-tab`: improves tab completion with an interactive picker.
- `starship`: fast prompt renderer.
- `zoxide`: smarter `cd`; use `z <partial-dir-name>`.
- `direnv`: loads per-project environment variables from `.envrc` after you
  approve them with `direnv allow`.
- `tmux`: terminal multiplexer for sessions, panes, and persistent terminals.
- `alacritty`: GPU-accelerated terminal on desktop Ubuntu.
- `Caskaydia Nerd Font`: Cascadia Code patched with developer icons; used by
  Alacritty and useful for Neovim/LazyVim symbols.

The zsh config also sets terminal titles. Local shells show host/current
directory, and `ssh user@host` changes the title to `ssh: host` until the SSH
session exits. Alacritty allows this because `dynamic_title = true`.

On WSL, terminal fonts are a Windows concern because Windows Terminal and
Windows Alacritty are Windows applications. The bootstrap installs the Nerd Font
Cascadia/Caskaydia package into the Windows user font directory, uses the
Windows-visible `CaskaydiaCove NFM` family, patches Windows Terminal with a
`Dotfiles Muted` color scheme, and writes a matching Windows Alacritty config to
`%APPDATA%\alacritty\alacritty.toml`.

## Editor

- `nvim`: installed from the official Neovim release when Ubuntu's version is
  too old for LazyVim.
- `LazyVim`: Neovim distribution used as the base editor setup.
- Enabled language extras include TypeScript, Angular, Vue, Svelte, Astro,
  Tailwind, JSON, YAML, TOML, Markdown, Docker, Go, Java, Python, SQL, Prisma,
  ESLint, Prettier, and REST files.

Most language servers and formatters are managed by LazyVim/Mason inside
Neovim. Project-specific formatters should still come from the project when a
lockfile/config exists.

## JavaScript And TypeScript

- `nvm`: manages Node versions per user.
- Node LTS: installed as the default Node version.
- `corepack`: ships with Node and manages package-manager shims.
- `pnpm`: activated through Corepack; good default package manager for modern JS
  projects.
- `bun`: fast JS runtime/package manager/test runner.

Angular CLI is intentionally not installed globally. Prefer project-local usage:

```bash
pnpm dlx @angular/cli new my-app
npx ng generate component feature-card
```

## Python

- `python3`, `python3-venv`, `python3-dev`, `python3-pip`: baseline Python
  development packages.
- `uv`: fast Python package/project/virtualenv tool.
- `pipx`: installs Python command-line apps in isolated environments.

Useful examples:

```bash
uv init my-project
uv venv
uv add requests
uv run python app.py
pipx install poetry
```

Use `uv` for project environments and dependency work. Use `pipx` when you want
a global Python CLI without polluting system Python.

## Go And Java

- `golang-go`: Go compiler/toolchain from Ubuntu.
- `openjdk-21-jdk`: Java 21 JDK.
- `maven`: Java build tool.

Gradle is not installed globally because Ubuntu's apt version is very old. Use a
project's `./gradlew` wrapper instead.

## CLI Utilities

- `ripgrep` (`rg`): fast code search.
- `fd-find` (`fdfind`): fast file finder; zsh aliases `fd` to `fdfind` when
  needed.
- `bat` (`batcat` on Ubuntu): `cat` with syntax highlighting.
- `eza`: modern `ls` replacement.
- `fzf`: fuzzy finder used by shell integrations and the `ff` helper.
- `jq`: JSON processor.
- `shellcheck`: shell script linter.
- `shfmt`: shell script formatter.
- `git-delta`: nicer git diff pager.
- `gh`: GitHub CLI.
- `tree-sitter-cli`: parser tooling used by editor/dev workflows.
