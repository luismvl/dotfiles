#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
INSTALL_PROFILE="desktop"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --server)
      INSTALL_PROFILE="server"
      ;;
    --desktop)
      INSTALL_PROFILE="desktop"
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: ./install.sh [--dry-run] [--server|--desktop]"
      exit 1
      ;;
  esac
  shift
done

if (( DRY_RUN == 1 )); then
  echo "Running in dry-run mode (no changes will be made)."
fi
echo "Install profile: $INSTALL_PROFILE"

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/install_lib.sh
source "$REPO_DIR/scripts/install_lib.sh"

run_cmd mkdir -p "$HOME/.config" "$HOME/.config/eza" "$HOME/.config/dotfiles" "$HOME/.zsh/plugins" "$HOME/.tmux/plugins" "$HOME/.codex"
if [[ "$INSTALL_PROFILE" == "desktop" ]]; then
  run_cmd mkdir -p "$HOME/.config/alacritty" "$HOME/.local/share/fonts"
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

if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
  echo "Note: nvm is not installed at $HOME/.nvm/nvm.sh."
  echo "Your zshrc keeps nvm loading in place; install nvm separately if needed."
fi

echo "Done. Restart shell with: exec zsh"
