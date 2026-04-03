#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$PROJECT_ROOT/dist"
TMP_DIR="$PROJECT_ROOT/build/love"
LOVE_FILE="$DIST_DIR/Pixelity.love"

mkdir -p "$DIST_DIR"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

cd "$PROJECT_ROOT"

zip -qr "$LOVE_FILE" \
  main.lua \
  conf.lua \
  src \
  assets \
  README.md \
  PROJECT_FILES.md \
  ARCHITECTURE_GUIDE.md \
  GAME_DESIGN.md

echo "Archive creee: $LOVE_FILE"
