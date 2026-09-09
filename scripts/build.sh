#!/usr/bin/env bash
set -euo pipefail
# lamX ISO build - run inside Codespaces / Arch with archiso
# usage: ./scripts/build.sh
PROFILE="$(dirname "$0")/../profile"
OUT="$(dirname "$0")/../out"
WORK="$(dirname "$0")/../work"

# stamp releases in IST dates, not UTC
export TZ=Asia/Kolkata
export SOURCE_DATE_EPOCH=$(date +%s)
echo "stamping $(date +%Y.%m.%d)"

sudo rm -rf "$OUT" "$WORK"
mkdir -p "$OUT" "$WORK"
sudo mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
sudo "$(dirname "$0")/repack-initramfs.sh" "$OUT"/*.iso
echo "ISO in $OUT"
ls -lh "$OUT"
