#!/usr/bin/env bash
# Installs the figma-to-native skill so your AI tools can use it.
#
# One command, no clone needed:
#   curl -fsSL https://raw.githubusercontent.com/BM-Ghost/figma-prompts/main/scripts/install.sh | bash -s -- --global
#
# It also runs from a clone of the repo: scripts/install.sh --global
set -euo pipefail

REPO="BM-Ghost/figma-prompts"
REF="${FIGMA_TO_NATIVE_REF:-main}"

usage() {
  cat <<'USAGE'
Usage: install.sh [target] [--global] [--dir <project-dir>]

Targets (default: all):
  claude        Claude Code
  agents        Codex CLI, Cursor, Devin and other tools that follow the open Agent Skills layout
  antigravity   Google Antigravity
  all           every target above

Scope:
  --global          install into your home folder, so every project on this computer can use it
  (default)         install into a project: the current directory, or --dir <path>

Where files go:
  claude        global: ~/.claude/skills       project: .claude/skills
  agents        global: ~/.agents/skills       project: .agents/skills
  antigravity   global: ~/.gemini/config/skills  project: .agents/skills

Environment:
  FIGMA_TO_NATIVE_REF   branch or tag to download when not run from a clone (default: main)

Works on macOS, Linux, WSL and Git Bash. Needs curl and tar when run without a clone.
USAGE
}

TARGET="all"
SCOPE="project"
PROJECT_DIR="$PWD"
while [ $# -gt 0 ]; do
  case "$1" in
    claude|agents|antigravity|all) TARGET="$1" ;;
    --global) SCOPE="global" ;;
    --dir) shift; PROJECT_DIR="${1:?--dir needs a path}" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

SELF="${BASH_SOURCE[0]:-}"
SRC=""
if [ -n "$SELF" ] && [ -f "$SELF" ]; then
  LOCAL_SRC="$(cd "$(dirname "$SELF")/.." && pwd)/skills/figma-to-native"
  [ -f "$LOCAL_SRC/SKILL.md" ] && SRC="$LOCAL_SRC"
fi

TMP=""
cleanup() { [ -n "$TMP" ] && rm -rf "$TMP"; return 0; }
trap cleanup EXIT

if [ -z "$SRC" ]; then
  command -v curl >/dev/null 2>&1 || { echo "curl is required to download the skill." >&2; exit 1; }
  command -v tar >/dev/null 2>&1 || { echo "tar is required to unpack the skill." >&2; exit 1; }
  TMP="$(mktemp -d)"
  echo "Downloading figma-to-native ($REF) from github.com/$REPO ..."
  curl -fsSL "https://codeload.github.com/$REPO/tar.gz/$REF" | tar -xz -C "$TMP"
  SRC="$(echo "$TMP"/*/skills/figma-to-native)"
  [ -f "$SRC/SKILL.md" ] || { echo "Download did not contain the skill." >&2; exit 1; }
fi

if [ "$SCOPE" = "global" ]; then BASE="$HOME"; else BASE="$PROJECT_DIR"; fi

skills_dir_for() {
  case "$1" in
    claude) echo "$BASE/.claude/skills" ;;
    agents) echo "$BASE/.agents/skills" ;;
    antigravity)
      if [ "$SCOPE" = "global" ]; then echo "$HOME/.gemini/config/skills"; else echo "$BASE/.agents/skills"; fi ;;
  esac
}

INSTALLED=""
install_target() {
  local dir dest
  dir="$(skills_dir_for "$1")"
  dest="$dir/figma-to-native"
  case "$INSTALLED" in *"|$dest|"*) return 0 ;; esac
  mkdir -p "$dir"
  rm -rf "$dest"
  cp -R "$SRC" "$dest"
  INSTALLED="$INSTALLED|$dest|"
  echo "Installed ($1): $dest"
}

if [ "$TARGET" = "all" ]; then
  install_target claude
  install_target agents
  install_target antigravity
else
  install_target "$TARGET"
fi

echo "Done. Restart your AI tool if it was already open, then send a Figma link and say: use figma-to-native."
