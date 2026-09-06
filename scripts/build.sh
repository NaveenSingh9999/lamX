#!/usr/bin/env bash
set -euo pipefail
# lamX ISO build - run inside Codespaces / Arch with archiso
# usage: ./scripts/build.sh
PROFILE="$(dirname "$0")/../profile"
OUT="$(dirname "$0")/../out"
WORK="$(dirname "$0")/../work"

sudo rm -rf "$OUT" "$WORK"
mkdir -p "$OUT" "$WORK"
sudo mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
echo "ISO in $OUT"
ls -lh "$OUT"
