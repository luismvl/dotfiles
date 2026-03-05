#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
INSTALL_PROFILE="desktop"
APPLY_ONLY=0
WITH_PERSONAL_TOOLS=0

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --dry-run             Print planned actions only
  --desktop             Desktop profile (default)
  --server              Dev-server profile (skip desktop-only system setup)
  --minimal             Alias of --apply-only
  --apply-only          Apply/render dotfiles config only (no apt/download/bootstrap)
  --with-personal-tools Also run personal tools bootstrap (scripts/bootstrap_codex.sh)
  -h, --help            Show this help

Mode matrix:
  ./install.sh
    - bootstrap_system: yes (desktop)
    - apply_dotfiles:   yes
    - bootstrap_codex:  no

  ./install.sh --server
    - bootstrap_system: yes (server)
    - apply_dotfiles:   yes
    - bootstrap_codex:  no

  ./install.sh --minimal
    - bootstrap_system: no
    - apply_dotfiles:   yes
    - bootstrap_codex:  no

  ./install.sh --with-personal-tools
    - bootstrap_system: yes (desktop)
    - apply_dotfiles:   yes
    - bootstrap_codex:  yes

  ./install.sh --server --with-personal-tools
    - bootstrap_system: yes (server)
    - apply_dotfiles:   yes
    - bootstrap_codex:  yes

  ./install.sh --minimal --with-personal-tools
    - bootstrap_system: no
    - apply_dotfiles:   yes
    - bootstrap_codex:  yes

Examples:
  ./install.sh --minimal
  ./install.sh --server --dry-run
  ./install.sh --minimal --with-personal-tools --dry-run
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --desktop)
      INSTALL_PROFILE="desktop"
      ;;
    --server)
      INSTALL_PROFILE="server"
      ;;
    --minimal|--apply-only)
      APPLY_ONLY=1
      ;;
    --with-personal-tools)
      WITH_PERSONAL_TOOLS=1
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

if (( DRY_RUN == 1 )); then
  echo "Running in dry-run mode (no changes will be made)."
fi

echo "Install orchestrator"
echo "  profile:             $INSTALL_PROFILE"
echo "  apply-only/minimal:  $APPLY_ONLY"
echo "  with personal tools: $WITH_PERSONAL_TOOLS"

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMMON_ARGS=(--profile "$INSTALL_PROFILE")
if (( DRY_RUN == 1 )); then
  COMMON_ARGS+=(--dry-run)
fi

if (( APPLY_ONLY == 0 )); then
  "$REPO_DIR/scripts/bootstrap_system.sh" "${COMMON_ARGS[@]}"
else
  echo "Skipping system bootstrap (apply-only mode)."
fi

"$REPO_DIR/scripts/apply_dotfiles.sh" "${COMMON_ARGS[@]}"

if (( WITH_PERSONAL_TOOLS == 1 )); then
  PERSONAL_ARGS=()
  if (( DRY_RUN == 1 )); then
    PERSONAL_ARGS+=(--dry-run)
  fi
  "$REPO_DIR/scripts/bootstrap_codex.sh" "${PERSONAL_ARGS[@]}"
else
  echo "Skipping personal tools bootstrap."
fi

if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
  echo "Note: nvm is not installed at $HOME/.nvm/nvm.sh."
  echo "Your zshrc keeps nvm loading in place; install nvm separately if needed."
fi

echo "Done. Restart shell with: exec zsh"
