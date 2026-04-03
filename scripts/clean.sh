#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

rm -rf "$PROJECT_ROOT/build"/*
rm -rf "$PROJECT_ROOT/dist"/*

echo "Dossiers build/ et dist/ nettoyes."
