#!/usr/bin/env bash
# Installs the figma-to-native skill so your AI tools can use it.
#
# Usage:
#   scripts/install.sh [target] [--global] [--dir <project-dir>]
#
# Targets (default: all):
#   claude        Claude Code
#   agents        Codex CLI, Cursor, Devin, and other tools that follow the open Agent Skills layout
#   antigravity   Google Antigravity
#   all           every target above
#
# Scope:
#   (default)         install into a project: the current directory, or --dir <path>
#   --global          install into your home folder, so every project on this computer can use it
#
# Where files go:
#   claude        project: .claude/skills            global: ~/.claude/skills
#   agents        project: .agents/skills            global: ~/.agents/skills
#   antigravity   project: .agents/skills            global: ~/.gemini/config/skills
#
# Works on macOS, Linux, WSL and Git Bash. On plain Windows, copy skills/figma-to-native
# into the folders listed above by hand.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/skills/figma-to-native"

TARGET="all"
SCOPE="project"
PROJECT_DIR="$PWD"
while [ $# -gt 0 ]; do
  case "$1" in
    claude|agents|antigravity|all) TARGET="$1" ;;
    --global) SCOPE="global" ;;
    --dir) shift; PROJECT_DIR="${1:?--dir needs a path}" ;;
    -h|--help) sed -n '2,23p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
  shift
done

[ -f "$SRC/SKILL.md" ] || { echo "Skill not found at $SRC" >&2; exit 1; }

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

echo "Done. Restart your AI tool if it was already open."
