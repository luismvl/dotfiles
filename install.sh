#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
INSTALL_PROFILE="desktop"
APPLY_ONLY=0
WITH_PERSONAL_TOOLS=0

yes_no() {
  if (( $1 == 1 )); then
    echo "yes"
  else
    echo "no"
  fi
}

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh
  ./install.sh server
  ./install.sh minimal
  ./install.sh tools
  ./install.sh server tools dry-run

Plain-English commands:
  server      Run the server profile (skip desktop-only terminal/font setup)
  minimal     Only apply dotfiles and render configs
  tools       Also run the Codex/bootstrap tools step
  dry-run     Show what would happen without changing anything
  help        Show this help

Readable flags:
  --server               Same as `server`
  --desktop              Force the desktop profile
  --minimal              Same as `minimal`
  --tools                Same as `tools`
  --dry-run              Same as `dry-run`

Older aliases still accepted:
  --apply-only           Old name for `--minimal`
  --personal-tools       Old name for `--tools`
  --with-personal-tools  Older name for `--tools`
  -h, --help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    dry|dry-run|--dry-run)
      DRY_RUN=1
      ;;
    desktop|--desktop)
      INSTALL_PROFILE="desktop"
      ;;
    server|--server)
      INSTALL_PROFILE="server"
      ;;
    minimal|apply|apply-only|--minimal|--apply-only)
      APPLY_ONLY=1
      ;;
    tools|--tools|personal-tools|--personal-tools|--with-personal-tools)
      WITH_PERSONAL_TOOLS=1
      ;;
    help|-h|--help)
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

echo "Install plan"
echo "  profile: $INSTALL_PROFILE"
echo "  system setup: $(yes_no $(( APPLY_ONLY == 0 )))"
echo "  apply config: yes"
echo "  codex tools:  $(yes_no "$WITH_PERSONAL_TOOLS")"
echo "  dry-run:      $(yes_no "$DRY_RUN")"

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMMON_ARGS=(--profile "$INSTALL_PROFILE")
if (( DRY_RUN == 1 )); then
  COMMON_ARGS+=(--dry-run)
fi

if (( APPLY_ONLY == 0 )); then
  "$REPO_DIR/scripts/bootstrap_system.sh" "${COMMON_ARGS[@]}"
else
  echo "Skipping system bootstrap (minimal mode)."
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
