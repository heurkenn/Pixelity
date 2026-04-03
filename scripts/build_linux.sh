#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$PROJECT_ROOT/tools/love-linux64"
DIST_DIR="$PROJECT_ROOT/dist/Pixelity-linux"
LOVE_FILE="$PROJECT_ROOT/dist/Pixelity.love"

"$PROJECT_ROOT/scripts/build_love.sh"

if [[ ! -d "$RUNTIME_DIR" ]]; then
  echo "Runtime Linux introuvable: $RUNTIME_DIR"
  echo "Ajoute le runtime officiel LOVE 11.5 Linux x64 extrait dans tools/love-linux64/"
  exit 1
fi

if [[ ! -x "$RUNTIME_DIR/love" ]]; then
  echo "Executable LOVE introuvable: $RUNTIME_DIR/love"
  exit 1
fi

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"
cp -R "$RUNTIME_DIR"/. "$DIST_DIR/"
cp "$LOVE_FILE" "$DIST_DIR/Pixelity.love"

cat > "$DIST_DIR/Pixelity" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="$SCRIPT_DIR:${LD_LIBRARY_PATH:-}"
exec "$SCRIPT_DIR/love" "$SCRIPT_DIR/Pixelity.love"
EOF

chmod +x "$DIST_DIR/Pixelity"

echo "Build Linux cree dans: $DIST_DIR"
echo "Lance ensuite: $DIST_DIR/Pixelity"
