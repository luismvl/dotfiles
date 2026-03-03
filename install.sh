#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
  echo "Running in dry-run mode (no changes will be made)."
fi

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/install_lib.sh
source "$REPO_DIR/scripts/install_lib.sh"

run_cmd mkdir -p "$HOME/.config" "$HOME/.config/eza" "$HOME/.config/alacritty" "$HOME/.config/dotfiles" "$HOME/.zsh/plugins" "$HOME/.tmux/plugins" "$HOME/.local/share/fonts"

install_apt_packages
install_zoxide
install_starship
ensure_neovim_min_version
set_default_terminal_alacritty
install_caskaydia_nerd_font
FONT_FAMILY="$(detect_caskaydia_nerd_family)"
write_alacritty_local_font_override "$FONT_FAMILY"

clone_plugin_if_missing "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.zsh/plugins/zsh-autosuggestions"
clone_plugin_if_missing "https://github.com/zsh-users/zsh-history-substring-search" "$HOME/.zsh/plugins/zsh-history-substring-search"
clone_plugin_if_missing "https://github.com/Aloxaf/fzf-tab" "$HOME/.zsh/plugins/fzf-tab"
clone_plugin_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting" "$HOME/.zsh/plugins/zsh-syntax-highlighting"
install_tmux_tpm

link_file "$REPO_DIR/zshrc" "$HOME/.config/dotfiles/zshrc"
ensure_main_zshrc_sources_dotfiles "$HOME/.config/dotfiles/zshrc"
link_file "$REPO_DIR/starship.toml" "$HOME/.config/starship.toml"
link_file "$REPO_DIR/eza/theme.yml" "$HOME/.config/eza/theme.yml"
link_file "$REPO_DIR/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
link_file "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf"
link_file "$REPO_DIR/nvim" "$HOME/.config/nvim"

if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
  echo "Note: nvm is not installed at $HOME/.nvm/nvm.sh."
  echo "Your zshrc keeps nvm loading in place; install nvm separately if needed."
fi

echo "Done. Restart shell with: exec zsh"
