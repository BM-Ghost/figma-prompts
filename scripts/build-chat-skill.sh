#!/usr/bin/env bash
# Builds dist/figma-to-native.zip, the upload package for Claude chat.
# The zip holds the skill folder at its root, which is the layout chat expects.
# Run from anywhere. Requires the `zip` command.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/dist/figma-to-native.zip"

mkdir -p "$ROOT/dist"
rm -f "$OUT"
(cd "$ROOT/skills" && zip -r -q "$OUT" figma-to-native)
echo "Built $OUT"
unzip -l "$OUT"
