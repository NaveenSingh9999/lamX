#!/usr/bin/env bash
set -euo pipefail
# lamX ISO build - run inside Codespaces / Arch with archiso
# usage: ./scripts/build.sh
PROFILE="$(dirname "$0")/../profile"
OUT="$(dirname "$0")/../out"
WORK="$(dirname "$0")/../work"
REPO="$(dirname "$0")/.."

# mkarchiso builds boot images from the HOST mkinitcpio config,
# so the live hooks are forced there for the build, host file restored after
sudo mkdir -p /etc/mkinitcpio.conf.d
sudo cp "$REPO/airootfs/etc/mkinitcpio.conf.d/archiso.conf" /etc/mkinitcpio.conf.d/
[ -f /etc/mkinitcpio.conf ] && sudo cp /etc/mkinitcpio.conf /tmp/mkinitcpio.conf.host-bak || true
printf '%s\n' 'MODULES=()' 'BINARIES=()' 'FILES=()' 'HOOKS=(base systemd autodetect microcode modconf kms memdisk archiso archiso_loop_mnt keyboard sd-vconsole block filesystems fsck)' | sudo tee /etc/mkinitcpio.conf >/dev/null
grep -q 'archiso' /etc/mkinitcpio.conf || { echo "hook setup failed"; exit 1; }

sudo rm -rf "$OUT" "$WORK"
mkdir -p "$OUT" "$WORK"
sudo mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
[ -f /tmp/mkinitcpio.conf.host-bak ] && sudo cp /tmp/mkinitcpio.conf.host-bak /etc/mkinitcpio.conf || true
echo "ISO in $OUT"
ls -lh "$OUT"
