#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"

case "$TARGET" in
  love)
    exec "$PROJECT_ROOT/scripts/build_love.sh"
    ;;
  linux)
    exec "$PROJECT_ROOT/scripts/build_linux.sh"
    ;;
  windows)
    exec "$PROJECT_ROOT/scripts/build_windows.sh"
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
