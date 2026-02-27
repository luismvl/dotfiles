#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
  echo "Running in dry-run mode (no changes will be made)."
fi

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

run_cmd() {
  if (( DRY_RUN == 1 )); then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

backup_path() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local stamp
    stamp="$(date +%Y%m%d-%H%M%S)"
    local backup="${target}.bak.${stamp}"
    if (( DRY_RUN == 1 )); then
      echo "[dry-run] Would back up existing $target -> $backup"
    else
      mv "$target" "$backup"
      echo "Backed up existing $target -> $backup"
    fi
  fi
}

link_file() {
  local src="$1"
  local dest="$2"

  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    echo "Already linked: $dest"
    return
  fi

  backup_path "$dest"
  run_cmd ln -sfn "$src" "$dest"
  if (( DRY_RUN == 1 )); then
    echo "[dry-run] Would link $dest -> $src"
  else
    echo "Linked $dest -> $src"
  fi
}

install_apt_packages() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get not found; skipping package install."
    return
  fi

  run_cmd sudo apt-get update

  local packages=(
    zsh
    git
    curl
    fzf
    ripgrep
    fd-find
    bat
    eza
    alacritty
  )

  local available=()
  local missing=()
  local pkg

  for pkg in "${packages[@]}"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      available+=("$pkg")
    else
      missing+=("$pkg")
    fi
  done

  if (( ${#available[@]} > 0 )); then
    run_cmd sudo apt-get install -y "${available[@]}"
  fi

  if (( ${#missing[@]} > 0 )); then
    echo "Packages not available in current apt sources: ${missing[*]}"
  fi
}

install_zoxide() {
  if command -v zoxide >/dev/null 2>&1; then
    echo "zoxide already installed"
    return
  fi

  if (( DRY_RUN == 1 )); then
    echo "[dry-run] Would install zoxide via official install script"
  else
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi
}

install_starship() {
  if command -v starship >/dev/null 2>&1; then
    echo "starship already installed"
    return
  fi

  if (( DRY_RUN == 1 )); then
    echo "[dry-run] Would install starship via official install script"
  else
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi
}

clone_plugin_if_missing() {
  local repo="$1"
  local dest="$2"

  if [[ -d "$dest/.git" ]]; then
    echo "Plugin already present: $dest"
    return
  fi

  if [[ -d "$dest" && ! -d "$dest/.git" ]]; then
    backup_path "$dest"
  fi

  run_cmd git clone "$repo" "$dest"
}

set_default_terminal_alacritty() {
  if ! command -v alacritty >/dev/null 2>&1; then
    echo "Note: alacritty not found on PATH; skipping default terminal setup."
    return
  fi

  local alacritty_path
  alacritty_path="$(command -v alacritty)"

  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
  fi

  if [[ "${ID:-}" == "ubuntu" ]] && command -v dpkg >/dev/null 2>&1 && dpkg --compare-versions "${VERSION_ID:-0}" ge "25.04"; then
    local terminals_file="$HOME/.config/ubuntu-xdg-terminals.list"
    local desktop_id="Alacritty.desktop"

    if (( DRY_RUN == 1 )); then
      echo "[dry-run] Would set $desktop_id first in $terminals_file"
      return
    fi

    if [[ -f "$terminals_file" ]]; then
      local tmp_file
      tmp_file="$(mktemp)"
      awk -v keep="$desktop_id" '$0 != keep { print }' "$terminals_file" > "$tmp_file"
      {
        printf '%s\n' "$desktop_id"
        cat "$tmp_file"
      } > "$terminals_file"
      rm -f "$tmp_file"
    else
      printf '%s\n' "$desktop_id" > "$terminals_file"
    fi

    echo "Configured default terminal in $terminals_file (Ubuntu 25.04+ behavior)."
    return
  fi

  if ! update-alternatives --query x-terminal-emulator >/dev/null 2>&1; then
    echo "Note: x-terminal-emulator alternatives group not available; skipping default terminal setup."
    return
  fi

  if ! update-alternatives --query x-terminal-emulator | grep -Fq "Alternative: $alacritty_path"; then
    run_cmd sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$alacritty_path" 50
  fi

  run_cmd sudo update-alternatives --set x-terminal-emulator "$alacritty_path"
  echo "Set default terminal to alacritty via update-alternatives."
}

run_cmd mkdir -p "$HOME/.config" "$HOME/.config/eza" "$HOME/.zsh/plugins"

install_apt_packages
install_zoxide
install_starship
set_default_terminal_alacritty

clone_plugin_if_missing "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.zsh/plugins/zsh-autosuggestions"
clone_plugin_if_missing "https://github.com/zsh-users/zsh-history-substring-search" "$HOME/.zsh/plugins/zsh-history-substring-search"
clone_plugin_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting" "$HOME/.zsh/plugins/zsh-syntax-highlighting"

link_file "$REPO_DIR/zshrc" "$HOME/.zshrc"
link_file "$REPO_DIR/starship.toml" "$HOME/.config/starship.toml"
link_file "$REPO_DIR/eza/theme.yml" "$HOME/.config/eza/theme.yml"

if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
  echo "Note: nvm is not installed at $HOME/.nvm/nvm.sh."
  echo "Your zshrc keeps nvm loading in place; install nvm separately if needed."
fi

echo "Done. Restart shell with: exec zsh"
