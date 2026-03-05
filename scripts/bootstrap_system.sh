#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
INSTALL_PROFILE="desktop"

usage() {
  cat <<'USAGE'
Usage: ./scripts/bootstrap_system.sh [options]

Options:
  --dry-run           Print planned actions only
  --profile <name>    desktop | server (default: desktop)
  --desktop           Shortcut for --profile desktop
  --server            Shortcut for --profile server
  -h, --help          Show help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --profile)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --profile"
        exit 1
      fi
      INSTALL_PROFILE="$2"
      shift
      ;;
    --desktop)
      INSTALL_PROFILE="desktop"
      ;;
    --server)
      INSTALL_PROFILE="server"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ "$INSTALL_PROFILE" != "desktop" && "$INSTALL_PROFILE" != "server" ]]; then
  echo "Invalid profile: $INSTALL_PROFILE (expected desktop|server)"
  exit 1
fi

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/install_lib.sh
source "$REPO_DIR/scripts/install_lib.sh"

echo "Bootstrap system"
echo "  dry-run: $DRY_RUN"
echo "  profile: $INSTALL_PROFILE"

run_cmd mkdir -p "$HOME/.zsh/plugins" "$HOME/.tmux/plugins"
if [[ "$INSTALL_PROFILE" == "desktop" ]]; then
  run_cmd mkdir -p "$HOME/.local/share/fonts" "$HOME/.config/alacritty"
fi

install_apt_packages "$INSTALL_PROFILE"
install_zoxide
install_starship
ensure_neovim_min_version

if [[ "$INSTALL_PROFILE" == "desktop" ]]; then
  set_default_terminal_alacritty
  install_caskaydia_nerd_font
  FONT_FAMILY="$(detect_caskaydia_nerd_family)"
  write_alacritty_local_font_override "$FONT_FAMILY"
else
  echo "Server profile: skipping Alacritty default-terminal and font setup."
fi

clone_plugin_if_missing "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.zsh/plugins/zsh-autosuggestions"
clone_plugin_if_missing "https://github.com/zsh-users/zsh-history-substring-search" "$HOME/.zsh/plugins/zsh-history-substring-search"
clone_plugin_if_missing "https://github.com/Aloxaf/fzf-tab" "$HOME/.zsh/plugins/fzf-tab"
clone_plugin_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting" "$HOME/.zsh/plugins/zsh-syntax-highlighting"
install_tmux_tpm

echo "System bootstrap complete."
