#!/usr/bin/env bash
# Builds every distributable from the single source skills/figma-to-native/SKILL.md:
#   dist/figma-to-native.zip           Upload package for Claude chat (custom skill)
#   dist/figma-to-native.prompt.md     Paste-ready prompt for any AI chat without skill support
# Run from anywhere. Requires `zip`.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$ROOT/skills/figma-to-native"
ZIP="$ROOT/dist/figma-to-native.zip"
PROMPT="$ROOT/dist/figma-to-native.prompt.md"

mkdir -p "$ROOT/dist"

rm -f "$ZIP"
(cd "$ROOT/skills" && zip -r -q "$ZIP" figma-to-native)

{
  cat <<'HEADER'
You are about to act as the figma-to-native skill. Follow every rule below for the whole conversation.
Wait for my first Figma component link. If I attach or paste Theme.swift or Theme.kt, treat them as the current theme.
If you cannot read Figma links, ask me for screenshots or specs instead of guessing.

----- RULES -----

HEADER
  awk 'BEGIN{fm=0} /^---$/ && fm<2 {fm++; next} fm>=2 {print}' "$SKILL_DIR/SKILL.md"
  printf '\nReply "Ready" and wait for the first Figma link.\n'
} > "$PROMPT"

echo "Built:"
ls -l "$ZIP" "$PROMPT"
