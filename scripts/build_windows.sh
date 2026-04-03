#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$PROJECT_ROOT/tools/love-win64"
DIST_DIR="$PROJECT_ROOT/dist/Pixelity-windows"
LOVE_FILE="$PROJECT_ROOT/dist/Pixelity.love"

"$PROJECT_ROOT/scripts/build_love.sh"

if [[ ! -d "$RUNTIME_DIR" ]]; then
  echo "Runtime Windows introuvable: $RUNTIME_DIR"
  echo "Ajoute le runtime officiel LOVE 11.5 Windows x64 extrait dans tools/love-win64/"
  exit 1
fi

if [[ ! -f "$RUNTIME_DIR/love.exe" ]]; then
  echo "Executable LOVE introuvable: $RUNTIME_DIR/love.exe"
  exit 1
fi

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"
cp -R "$RUNTIME_DIR"/. "$DIST_DIR/"
cat "$RUNTIME_DIR/love.exe" "$LOVE_FILE" > "$DIST_DIR/Pixelity.exe"
rm -f "$DIST_DIR/love.exe"

echo "Build Windows cree dans: $DIST_DIR"
echo "Pixelity.exe doit rester avec les DLL du runtime LOVE."
