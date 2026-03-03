#!/usr/bin/env bash

run_cmd() {
  if (( DRY_RUN == 1 )); then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

warn_continue() {
  echo "Warning: $*"
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

ensure_main_zshrc_sources_dotfiles() {
  local dotfiles_zshrc="$1"
  local main_zshrc="$HOME/.zshrc"
  local start_marker="# >>> dotfiles-zsh >>>"
  local end_marker="# <<< dotfiles-zsh <<<"
  local block
  block="$start_marker
[ -f \"$dotfiles_zshrc\" ] && source \"$dotfiles_zshrc\"
$end_marker"

  if (( DRY_RUN == 1 )); then
    if [[ -L "$main_zshrc" ]]; then
      echo "[dry-run] Would replace symlinked $main_zshrc with a regular file containing dotfiles source block"
    elif [[ -f "$main_zshrc" ]]; then
      echo "[dry-run] Would upsert dotfiles source block in $main_zshrc"
    else
      echo "[dry-run] Would create $main_zshrc with dotfiles source block"
    fi
    return
  fi

  if [[ -L "$main_zshrc" ]]; then
    backup_path "$main_zshrc"
    printf '%s\n' "$block" > "$main_zshrc"
    echo "Created regular $main_zshrc with dotfiles source block"
    return
  fi

  if [[ ! -f "$main_zshrc" ]]; then
    printf '%s\n' "$block" > "$main_zshrc"
    echo "Created $main_zshrc with dotfiles source block"
    return
  fi

  if grep -Fq "$start_marker" "$main_zshrc" && grep -Fq "$end_marker" "$main_zshrc"; then
    local tmp_file
    tmp_file="$(mktemp)"
    awk -v start="$start_marker" -v end="$end_marker" -v block="$block" '
      BEGIN { in_block = 0; replaced = 0 }
      $0 == start {
        if (!replaced) {
          print block
          replaced = 1
        }
        in_block = 1
        next
      }
      $0 == end {
        in_block = 0
        next
      }
      !in_block { print }
      END {
        if (!replaced) {
          if (NR > 0) print ""
          print block
        }
      }
    ' "$main_zshrc" > "$tmp_file"
    mv "$tmp_file" "$main_zshrc"
    echo "Updated dotfiles source block in $main_zshrc"
  else
    {
      printf '\n'
      printf '%s\n' "$block"
    } >> "$main_zshrc"
    echo "Appended dotfiles source block to $main_zshrc"
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
    neovim
    build-essential
    unzip
    xclip
    tree-sitter-cli
    fzf
    ripgrep
    fd-find
    bat
    eza
    alacritty
    tmux
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

install_neovim_latest() {
  local arch asset_name url
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64)
      asset_name="nvim-linux-x86_64.tar.gz"
      ;;
    aarch64|arm64)
      asset_name="nvim-linux-arm64.tar.gz"
      ;;
    *)
      warn_continue "Unsupported architecture for automatic Neovim tarball install: $arch"
      return 1
      ;;
  esac

  url="https://github.com/neovim/neovim/releases/latest/download/$asset_name"

  if (( DRY_RUN == 1 )); then
    echo "[dry-run] Would install Neovim latest from $url into $HOME/.local"
    return 0
  fi

  local tmpdir archive extract_dir
  tmpdir="$(mktemp -d)"
  archive="$tmpdir/$asset_name"

  if ! curl -fL "$url" -o "$archive" >/dev/null 2>&1; then
    warn_continue "Failed to download Neovim tarball ($url)"
    rm -rf "$tmpdir"
    return 1
  fi

  extract_dir="$HOME/.local"
  mkdir -p "$extract_dir" "$HOME/.local/bin"
  rm -rf "$extract_dir/nvim-linux-x86_64" "$extract_dir/nvim-linux-arm64"

  if ! tar -xzf "$archive" -C "$extract_dir" >/dev/null 2>&1; then
    warn_continue "Failed to extract Neovim tarball."
    rm -rf "$tmpdir"
    return 1
  fi
  rm -rf "$tmpdir"

  local extracted_dir
  extracted_dir="${asset_name%.tar.gz}"
  run_cmd ln -sfn "$extract_dir/$extracted_dir/bin/nvim" "$HOME/.local/bin/nvim"
  echo "Installed Neovim latest to $extract_dir/$extracted_dir"
  return 0
}

ensure_neovim_min_version() {
  local required="0.11.2"
  local current=""

  if command -v nvim >/dev/null 2>&1; then
    current="$(nvim --version 2>/dev/null | head -n1 | grep -Eo '[0-9]+\\.[0-9]+\\.[0-9]+' | head -n1 || true)"
  fi

  if [[ -n "$current" ]] && command -v dpkg >/dev/null 2>&1 && dpkg --compare-versions "$current" ge "$required"; then
    echo "Neovim version $current is compatible (>= $required)."
    return
  fi

  if [[ -n "$current" ]]; then
    echo "Neovim version $current is below required $required for LazyVim. Installing latest..."
  else
    echo "Neovim not found. Installing latest..."
  fi

  if ! install_neovim_latest; then
    warn_continue "Could not install Neovim latest automatically. LazyVim needs Neovim >= $required."
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

install_tmux_tpm() {
  local dest="$HOME/.tmux/plugins/tpm"
  clone_plugin_if_missing "https://github.com/tmux-plugins/tpm" "$dest"
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

install_caskaydia_nerd_font() {
  local api_url="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
  local install_dir="$HOME/.local/share/fonts/CaskaydiaCoveNerdFont"

  if (( DRY_RUN == 1 )); then
    echo "[dry-run] Would fetch latest Nerd Fonts release metadata from GitHub"
    echo "[dry-run] Would download CascadiaCode.tar.xz and reinstall into $install_dir"
    echo "[dry-run] Would run fc-cache -f"
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    warn_continue "curl not found; skipping Caskaydia Nerd Font install."
    return
  fi

  local release_json asset_url tmpdir archive
  if ! release_json="$(curl -fsSL "$api_url" 2>/dev/null)"; then
    warn_continue "Failed to query Nerd Fonts latest release; skipping Caskaydia font install."
    return
  fi

  asset_url="$(printf '%s\n' "$release_json" | grep -o 'https://[^"]*CascadiaCode.tar.xz' | head -n1 || true)"
  if [[ -z "$asset_url" ]]; then
    warn_continue "Could not find CascadiaCode.tar.xz in Nerd Fonts latest release; skipping font install."
    return
  fi

  tmpdir="$(mktemp -d)"
  archive="$tmpdir/CascadiaCode.tar.xz"

  if ! curl -fL "$asset_url" -o "$archive" >/dev/null 2>&1; then
    warn_continue "Failed to download Caskaydia Nerd Font archive; skipping font install."
    rm -rf "$tmpdir"
    return
  fi

  rm -rf "$install_dir"
  mkdir -p "$install_dir"

  if ! tar -xJf "$archive" -C "$install_dir" >/dev/null 2>&1; then
    warn_continue "Failed to extract Caskaydia Nerd Font archive; skipping font install."
    rm -rf "$tmpdir"
    return
  fi

  rm -rf "$tmpdir"

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f >/dev/null 2>&1 || warn_continue "fc-cache failed; fonts may not be immediately visible."
  else
    warn_continue "fc-cache not found; fonts may not be immediately visible."
  fi

  echo "Installed Caskaydia Nerd Font to $install_dir"
}

detect_caskaydia_nerd_family() {
  local fallback="CaskaydiaCove Nerd Font"
  if ! command -v fc-list >/dev/null 2>&1; then
    printf '%s\n' "$fallback"
    return
  fi

  local families
  families="$(fc-list : family 2>/dev/null | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | awk 'NF' | sort -u || true)"
  if [[ -z "$families" ]]; then
    printf '%s\n' "$fallback"
    return
  fi

  local candidates=(
    "CaskaydiaCove Nerd Font Mono"
    "CaskaydiaCove Nerd Font"
    "CascadiaCode Nerd Font Mono"
    "CascadiaCode Nerd Font"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if printf '%s\n' "$families" | grep -Fxq "$candidate"; then
      printf '%s\n' "$candidate"
      return
    fi
  done

  printf '%s\n' "$fallback"
}

write_alacritty_local_font_override() {
  local family="$1"
  local target="$HOME/.config/alacritty/local-font.toml"
  local escaped_family
  escaped_family="${family//\"/\\\"}"

  if (( DRY_RUN == 1 )); then
    echo "[dry-run] Would write $target with detected font family: $family"
    return
  fi

  mkdir -p "$HOME/.config/alacritty"
  cat > "$target" <<EOF2
[font]
size = 12.0

[font.normal]
family = "$escaped_family"
style = "Regular"

[font.bold]
family = "$escaped_family"
style = "Bold"

[font.italic]
family = "$escaped_family"
style = "Italic"

[font.bold_italic]
family = "$escaped_family"
style = "Bold Italic"
EOF2
  echo "Wrote Alacritty local font override: $target (family: $family)"
}
