#!/usr/bin/env bash
set -euo pipefail
# lamX ISO build - run inside Codespaces / Arch with archiso
# usage: ./scripts/build.sh
PROFILE="$(dirname "$0")/../profile"
OUT="$(dirname "$0")/../out"
WORK="$(dirname "$0")/../work"
REPO="$(dirname "$0")/.."

# mkarchiso builds boot images from the HOST mkinitcpio config,
# so the archiso hooks must live on the host too, not just airootfs
sudo mkdir -p /etc/mkinitcpio.conf.d
sudo cp "$REPO/airootfs/etc/mkinitcpio.conf.d/archiso.conf" /etc/mkinitcpio.conf.d/

sudo rm -rf "$OUT" "$WORK"
mkdir -p "$OUT" "$WORK"
sudo mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
echo "ISO in $OUT"
ls -lh "$OUT"
