#!/usr/bin/env bash
set -euo pipefail
# lamX ISO build - run inside Codespaces / Arch with archiso
# usage: ./scripts/build.sh
PROFILE="$(dirname "$0")/../profile"
OUT="$(dirname "$0")/../out"
WORK="$(dirname "$0")/../work"
REPO="$(dirname "$0")/.."

# mkarchiso builds boot images from the HOST mkinitcpio config,
# and only the main file is honored, so patch the hooks in place
sudo mkdir -p /etc/mkinitcpio.conf.d
sudo cp "$REPO/airootfs/etc/mkinitcpio.conf.d/archiso.conf" /etc/mkinitcpio.conf.d/
sudo sed -i 's/ kms keyboard / kms memdisk archiso archiso_loop_mnt keyboard /' /etc/mkinitcpio.conf
grep -q 'archiso' /etc/mkinitcpio.conf || { echo "hook patch failed"; exit 1; }

sudo rm -rf "$OUT" "$WORK"
mkdir -p "$OUT" "$WORK"
sudo mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
echo "ISO in $OUT"
ls -lh "$OUT"
