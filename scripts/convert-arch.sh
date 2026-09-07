#!/usr/bin/env bash
set -euo pipefail
# convert-arch.sh - turn a running Arch minimal VM into lamX userspace, no wipe
# safe for rented VMs: never touches partitions, LUKS, or bootloader
# usage: sudo ./scripts/convert-arch.sh [username]
# username defaults to the sudo caller; TPM/PIN steps are skipped on VMs
USERN="${1:-${SUDO_USER:-}}"
[ -n "$USERN" ] || { echo "usage: sudo ./scripts/convert-arch.sh [username]"; exit 1; }
id "$USERN" >/dev/null 2>&1 || { echo "user $USERN does not exist"; exit 1; }
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP="/root/lamx-backup-$(date +%Y%m%d-%H%M)"
echo "[1/7] backup /etc to $BACKUP"
mkdir -p "$BACKUP"
cp -a /etc "$BACKUP/" || true

echo "[2/7] add CachyOS generic + chaotic-aur repos"
pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com || true
pacman-key --lsign-key F3B607488DB35A47 || true
pacman -U --noconfirm \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-27-1-any.pkg.tar.zst' || true
grep -q "^\[cachyos\]" /etc/pacman.conf || printf '\n[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n' >> /etc/pacman.conf
pacman-key --recv-keys 3056513887B78AEB --keyserver keyserver.ubuntu.com || true
pacman-key --lsign-key 3056513887B78AEB || true
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' || true
grep -q "^\[chaotic-aur\]" /etc/pacman.conf || printf '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n' >> /etc/pacman.conf
pacman -Sy --noconfirm

echo "[3/7] install lamX package set from profile"
PKGS=$(grep -vE '^\s*(#|$)' "$REPO_DIR/profile/packages.x86_64" | tr '\n' ' ')
# shellcheck disable=SC2086
pacman -S --noconfirm --needed $PKGS || echo "WARN: some packages failed, continuing"
pacman -S --noconfirm --needed swayfx swaylock-effects opencode-bin || echo "WARN: glassy extras skipped"

echo "[4/7] copy lamX configs, excluding identity and disk files"
EXCL=(etc/shadow etc/gshadow etc/passwd etc/group etc/fstab etc/crypttab etc/crypttab.initramfs etc/hostname etc/machine-id etc/adjtime)
TAR_EXCL=()
for e in "${EXCL[@]}"; do TAR_EXCL+=(--exclude="$e"); done
tar -C "$REPO_DIR/airootfs" -cf - "${TAR_EXCL[@]}" . | tar -C / -xf -
cp "$REPO_DIR/profile/mkinitcpio.conf.lamx" /etc/mkinitcpio.conf
mkinitcpio -P 2>/dev/null || echo "initramfs regen skipped"
echo "overlay copied, excluded: ${EXCL[*]}"

echo "[5/7] user groups and shell defaults"
usermod -aG wheel,video,audio,seat,libvirt,kvm "$USERN" || true
cp -rn /etc/skel/. "/home/$USERN/" 2>/dev/null || true
chown -R "$USERN:$USERN" "/home/$USERN" 2>/dev/null || true
grep -q "config.d/fx" /etc/sway/config.d/lamx 2>/dev/null || echo "include /etc/sway/config.d/fx" >> /etc/sway/config.d/lamx || true

echo "[6/7] enable services (console only, SSH unaffected)"
systemctl enable NetworkManager seatd greetd apparmor chronyd power-profiles-daemon systemd-resolved systemd-oomd auditd kzc-monitor kzc-head opencode-kzc thermald ananicy-cpp libvirtd "syncthing@$USERN" 2>/dev/null || true
systemctl enable snapper-timeline.timer snapper-cleanup.timer fwupd-refresh.timer kzc-aide.timer fstrim.timer plocate-updatedb.timer 2>/dev/null || true
snapper -c root create-config / 2>/dev/null || echo "snapper skipped, not btrfs"
systemctl mask bluetooth NetworkManager-wait-online.service 2>/dev/null || true
systemctl --global enable kzc-digest.timer 2>/dev/null || true

echo "[7/7] passwordless: same wiring as installer, see lamx-setup pam-wire"
echo "  1. test in a second SSH session before logging out"
echo "  2. run lamx-setup to enroll keys and wire sudo, greetd, lock"
echo ""
echo "done. backup at $BACKUP"
echo "reboot only if console access is available, SSH survives without reboot"
echo "run: lamx-help, lamx list, systemctl status kzc-monitor"
