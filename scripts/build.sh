#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"
DIST_DIR="$PROJECT_ROOT/dist"
LOVE_FILE="$DIST_DIR/Pixelity.love"

build_love_archive() {
  mkdir -p "$DIST_DIR"
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
}

build_linux_package() {
  local runtime_dir="$PROJECT_ROOT/tools/love-linux64"
  local linux_dist_dir="$PROJECT_ROOT/dist/Pixelity-linux"

  build_love_archive

  if [[ ! -d "$runtime_dir" ]]; then
    echo "Runtime Linux introuvable: $runtime_dir"
    echo "Ajoute le runtime officiel LOVE 11.5 Linux x64 extrait dans tools/love-linux64/"
    exit 1
  fi

  if [[ ! -x "$runtime_dir/love" ]]; then
    echo "Executable LOVE introuvable: $runtime_dir/love"
    exit 1
  fi

  rm -rf "$linux_dist_dir"
  mkdir -p "$linux_dist_dir"
  cp -R "$runtime_dir"/. "$linux_dist_dir/"
  cp "$LOVE_FILE" "$linux_dist_dir/Pixelity.love"

  cat > "$linux_dist_dir/Pixelity" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="$SCRIPT_DIR:${LD_LIBRARY_PATH:-}"
exec "$SCRIPT_DIR/love" "$SCRIPT_DIR/Pixelity.love"
EOF

  chmod +x "$linux_dist_dir/Pixelity"

  echo "Build Linux cree dans: $linux_dist_dir"
  echo "Lance ensuite: $linux_dist_dir/Pixelity"
}

build_windows_package() {
  local runtime_dir="$PROJECT_ROOT/tools/love-win64"
  local windows_dist_dir="$PROJECT_ROOT/dist/Pixelity-windows"

  build_love_archive

  if [[ ! -d "$runtime_dir" ]]; then
    echo "Runtime Windows introuvable: $runtime_dir"
    echo "Ajoute le runtime officiel LOVE 11.5 Windows x64 extrait dans tools/love-win64/"
    exit 1
  fi

  if [[ ! -f "$runtime_dir/love.exe" ]]; then
    echo "Executable LOVE introuvable: $runtime_dir/love.exe"
    exit 1
  fi

  rm -rf "$windows_dist_dir"
  mkdir -p "$windows_dist_dir"
  cp -R "$runtime_dir"/. "$windows_dist_dir/"
  cat "$runtime_dir/love.exe" "$LOVE_FILE" > "$windows_dist_dir/Pixelity.exe"
  rm -f "$windows_dist_dir/love.exe"

  echo "Build Windows cree dans: $windows_dist_dir"
  echo "Pixelity.exe doit rester avec les DLL du runtime LOVE."
}

case "$TARGET" in
  love)
    build_love_archive
    ;;
  linux)
    build_linux_package
    ;;
  windows)
    build_windows_package
    ;;
  *)
    cat <<'EOF'
Usage:
  ./scripts/build.sh love
  ./scripts/build.sh linux
  ./scripts/build.sh windows
EOF
    exit 1
    ;;
esac
