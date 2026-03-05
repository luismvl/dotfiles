#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
INSTALL_CLI=1
SYNC_SKILLS=1

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_PATH="$REPO_DIR/codex/skills.manifest"

usage() {
  cat <<'USAGE'
Usage: ./scripts/bootstrap_codex.sh [options]

Options:
  --dry-run          Print planned actions without changing anything
  --skip-cli         Do not install/update Codex CLI
  --skip-skills      Do not sync skills from manifest
  --manifest <path>  Use custom skills manifest (default: codex/skills.manifest)
  -h, --help         Show this help

Manifest format (pipe-delimited):
  name|source|mode

Modes:
  symlink  Source is a local path; links into ~/.codex/skills/<name>
  clone    Source is a git URL; clones/pulls into ~/.codex/skills/<name>
  copy     Source is a local path; copies into ~/.codex/skills/<name>

Examples:
  agent-browser|$HOME/.agents/skills/agent-browser|symlink
  my-skill|git@github.com:org/skill-repo.git|clone
USAGE
}

run_cmd() {
  if (( DRY_RUN == 1 )); then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

warn() {
  echo "Warning: $*"
}

backup_path() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local stamp
    stamp="$(date +%Y%m%d-%H%M%S)"
    local backup="${target}.bak.${stamp}"
    if (( DRY_RUN == 1 )); then
      echo "[dry-run] Would back up $target -> $backup"
    else
      mv "$target" "$backup"
      echo "Backed up $target -> $backup"
    fi
  fi
}

trim() {
  local s="$1"
  s="${s#${s%%[![:space:]]*}}"
  s="${s%${s##*[![:space:]]}}"
  printf '%s' "$s"
}

expand_home() {
  local s="$1"
  s="${s/#\~/$HOME}"
  s="${s//\$HOME/$HOME}"
  printf '%s' "$s"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --skip-cli)
      INSTALL_CLI=0
      ;;
    --skip-skills)
      SYNC_SKILLS=0
      ;;
    --manifest)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --manifest"
        exit 1
      fi
      MANIFEST_PATH="$2"
      shift
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

echo "Codex bootstrap"
echo "  dry-run:      $DRY_RUN"
echo "  install cli:  $INSTALL_CLI"
echo "  sync skills:  $SYNC_SKILLS"
echo "  manifest:     $MANIFEST_PATH"

if (( INSTALL_CLI == 1 )); then
  if command -v codex >/dev/null 2>&1; then
    echo "Codex CLI already installed: $(command -v codex)"
  else
    if ! command -v npm >/dev/null 2>&1; then
      warn "npm not found; cannot install Codex CLI automatically."
    else
      run_cmd npm install -g @openai/codex
    fi
  fi
fi

if (( SYNC_SKILLS == 1 )); then
  if [[ ! -f "$MANIFEST_PATH" ]]; then
    warn "Skills manifest not found: $MANIFEST_PATH"
    warn "Copy codex/skills.manifest.example to codex/skills.manifest and edit it."
    exit 0
  fi

  run_cmd mkdir -p "$HOME/.codex/skills"

  while IFS='|' read -r raw_name raw_source raw_mode; do
    raw_name="$(trim "${raw_name:-}")"
    raw_source="$(trim "${raw_source:-}")"
    raw_mode="$(trim "${raw_mode:-}")"

    [[ -z "$raw_name" ]] && continue
    [[ "$raw_name" =~ ^# ]] && continue
    [[ -z "$raw_source" ]] && { warn "Skipping '$raw_name': missing source"; continue; }

    local_name="$raw_name"
    local_source="$(expand_home "$raw_source")"
    local_mode="${raw_mode:-symlink}"
    dest="$HOME/.codex/skills/$local_name"

    case "$local_mode" in
      symlink)
        if [[ ! -e "$local_source" ]]; then
          warn "Skipping '$local_name': source does not exist ($local_source)"
          continue
        fi
        run_cmd ln -sfn "$local_source" "$dest"
        echo "Linked skill: $local_name -> $local_source"
        ;;
      clone)
        if [[ -d "$dest/.git" ]]; then
          run_cmd git -C "$dest" pull --ff-only
          echo "Updated skill repo: $local_name"
        else
          run_cmd git clone "$local_source" "$dest"
          echo "Cloned skill repo: $local_name"
        fi
        ;;
      copy)
        if [[ ! -e "$local_source" ]]; then
          warn "Skipping '$local_name': source does not exist ($local_source)"
          continue
        fi
        if (( DRY_RUN == 1 )); then
          echo "[dry-run] Would copy $local_source -> $dest"
        else
          backup_path "$dest"
          cp -a "$local_source" "$dest"
          echo "Copied skill: $local_name"
        fi
        ;;
      *)
        warn "Skipping '$local_name': unknown mode '$local_mode'"
        ;;
    esac
  done < "$MANIFEST_PATH"
fi

echo "Bootstrap complete."
