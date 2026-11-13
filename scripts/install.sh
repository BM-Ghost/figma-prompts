#!/usr/bin/env bash
# Installs the figma-to-native skill into a project or your home folder.
#
# Usage:
#   scripts/install.sh [target] [--global] [--dir <project-dir>]
#
# Targets:
#   claude   .claude/skills       Claude Code
#   agents   .agents/skills       Devin, Codex CLI and other agents that follow the open Agent Skills layout
#   all      both of the above (default)
#
# Options:
#   --global       Install into your home folder instead of a project
#   --dir <path>   Project directory to install into (default: current directory)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/skills/figma-to-native"

TARGET="all"
BASE="$PWD"
while [ $# -gt 0 ]; do
  case "$1" in
    claude|agents|all) TARGET="$1" ;;
    --global) BASE="$HOME" ;;
    --dir) shift; BASE="${1:?--dir needs a path}" ;;
    -h|--help) sed -n '2,16p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
  shift
done

[ -f "$SRC/SKILL.md" ] || { echo "Skill not found at $SRC" >&2; exit 1; }

install_into() {
  local dest="$BASE/$1/figma-to-native"
  mkdir -p "$BASE/$1"
  rm -rf "$dest"
  cp -R "$SRC" "$dest"
  echo "Installed: $dest"
}

case "$TARGET" in
  claude) install_into ".claude/skills" ;;
  agents) install_into ".agents/skills" ;;
  all) install_into ".claude/skills"; install_into ".agents/skills" ;;
esac
