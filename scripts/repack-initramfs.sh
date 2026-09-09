#!/usr/bin/env bash
set -euo pipefail
# repack-initramfs - rebuild the ISO boot images with live hooks, in place
# mkarchiso bakes boot images during package install, before the overlay
# with our hooks lands. this extracts, rebuilds inside the real root with
# our mkinitcpio.conf.d present, and swaps the images back preserving boot.
# usage: sudo ./scripts/repack-initramfs.sh out/lamX-*.iso
ISO="${1:-}"
[ -f "$ISO" ] || { echo "usage: sudo $0 <iso>"; exit 1; }
[ "$EUID" -eq 0 ] || exec sudo "$0" "$@"
TMP="$(mktemp -d)"
cleanup() { umount "$TMP/sqsh" 2>/dev/null || true; rm -rf "$TMP"; }
trap cleanup EXIT
command -v xorriso >/dev/null || pacman -S --noconfirm libisoburn
command -v isoinfo >/dev/null || pacman -S --noconfirm cdrtools
command -v unsquashfs >/dev/null || pacman -S --noconfirm squashfs-tools
command -v arch-chroot >/dev/null || pacman -S --noconfirm arch-install-scripts
echo "[1/4] extract ISO"
xorriso -osirrox on -indev "$ISO" -extract / "$TMP/iso"
SFS=$(echo "$TMP"/iso/*/x86_64/airootfs.sfs)
[ -f "$SFS" ] || { echo "airootfs image not found"; exit 1; }
echo "[2/4] unsquash root"
unsquashfs -d "$TMP/sqsh" "$SFS" >/dev/null
REPO="$(cd "$(dirname "$0")/.." && pwd)"
if [ ! -f "$TMP/sqsh/etc/mkinitcpio.conf.d/archiso.conf" ]; then
  echo "drop-in missing from image, planting from repo"
  mkdir -p "$TMP/sqsh/etc/mkinitcpio.conf.d"
  cp "$REPO/profile/airootfs/etc/mkinitcpio.conf.d/archiso.conf" "$TMP/sqsh/etc/mkinitcpio.conf.d/"
fi
echo "restoring kernel into chroot, mkarchiso moved it out"
mkdir -p "$TMP/sqsh/boot"
find "$TMP/iso" -name 'vmlinuz-*' -exec cp {} "$TMP/sqsh/boot/" \;
ls "$TMP/sqsh/boot/"
echo "[3/4] rebuild initramfs inside real root"
arch-chroot "$TMP/sqsh" mkinitcpio -P
echo "[4/4] swap images back into ISO"
for img in "$TMP"/sqsh/boot/initramfs-*.img; do
  base=$(basename "$img")
  dest=$(find "$TMP/iso" -name "$base" | head -n1)
  [ -n "$dest" ] || { echo "no slot for $base"; exit 1; }
  isopath="/${dest#"$TMP/iso/"}"
  xorriso -dev "$ISO" -update "$img" "$isopath" -commit >/dev/null
  echo "updated $isopath"
done
echo "verifying El Torito boot record survived"
isoinfo -d -i "$ISO" | grep -qi "eltorito" || { echo "BOOT-RECORD-BROKEN"; exit 1; }
echo "repacked $ISO"
