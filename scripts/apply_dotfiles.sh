#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
INSTALL_PROFILE="desktop"

usage() {
  cat <<'USAGE'
Usage: ./scripts/apply_dotfiles.sh [options]

Options:
  --dry-run           Print planned changes only
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

echo "Apply dotfiles"
echo "  dry-run: $DRY_RUN"
echo "  profile: $INSTALL_PROFILE"

run_cmd mkdir -p "$HOME/.config" "$HOME/.config/eza" "$HOME/.config/dotfiles" "$HOME/.codex"
if [[ "$INSTALL_PROFILE" == "desktop" ]]; then
  run_cmd mkdir -p "$HOME/.config/alacritty"
fi

link_file "$REPO_DIR/zshrc" "$HOME/.config/dotfiles/zshrc"
ensure_main_zshrc_sources_dotfiles "$HOME/.config/dotfiles/zshrc"
link_file "$REPO_DIR/starship.toml" "$HOME/.config/starship.toml"
link_file "$REPO_DIR/eza/theme.yml" "$HOME/.config/eza/theme.yml"
if [[ "$INSTALL_PROFILE" == "desktop" ]]; then
  link_file "$REPO_DIR/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
fi
link_file "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf"
link_file "$REPO_DIR/nvim" "$HOME/.config/nvim"

render_codex_config "$REPO_DIR/codex/config.base.toml" "$REPO_DIR/codex/config.local.env" "$HOME/.codex/config.toml"

echo "Apply complete."
