#!/usr/bin/env bash
set -euo pipefail
# lamX installer - single-user, LUKS2 + TPM2+PIN, Sway, CLI-first
# usage: sudo ./scripts/install.sh /dev/nvme0n1
DISK="${1:-}"
USERN="${2:-lamx}"
HOSTN="lamx"
if [ -z "$DISK" ]; then
  echo "usage: sudo ./scripts/install.sh /dev/nvme0n1 [username]"
  echo "WARNING: wipes \$DISK"
  exit 1
fi
read -rp "Wipe $DISK and install lamX? [y/N] " c
[ "$c" = "y" ] || exit 1

parted -s "$DISK" mklabel gpt mkpart ESP fat32 1MiB 513MiB set 1 esp on mkpart root 513MiB 100%
ESP="${DISK}p1"; ROOT="${DISK}p2"
[ -e "$ESP" ] || { ESP="${DISK}1"; ROOT="${DISK}2"; }
mkfs.fat -F32 "$ESP"
echo "Enter LUKS PIN-backed passphrase once, then it will be enrolled to TPM2+PIN:"
cryptsetup luksFormat --type luks2 "$ROOT"
cryptsetup open "$ROOT" lamxroot
mkfs.btrfs -L lamx /dev/mapper/lamxroot
mount /dev/mapper/lamxroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt
mount -o subvol=@,compress=zstd,noatime /dev/mapper/lamxroot /mnt
mkdir -p /mnt/home /mnt/boot
mount -o subvol=@home,compress=zstd,noatime /dev/mapper/lamxroot /mnt/home
mount "$ESP" /mnt/boot

# package set is single-sourced from the ISO profile, never hardcoded here
PKGS=$(grep -vE '^\s*(#|$)' profile/packages.x86_64 | tr '\n' ' ')
# shellcheck disable=SC2086
pacstrap -K /mnt $PKGS
# extras post-install via chaotic-aur: swayfx glassy, blur lock, opencode head
arch-chroot /mnt bash -c "pacman-key --recv-keys 3056513887B78AEB --keyserver keyserver.ubuntu.com && pacman-key --lsign-key 3056513887B78AEB && pacman -U --noconfirm https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst && echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf && pacman -Sy --noconfirm && pacman -S --noconfirm swayfx swaylock-effects opencode-bin quickemu mpvpaper eww mpv-mpris zen-browser-bin && /usr/local/bin/lamx-glassy on" || echo "extras skipped, install manually later"
ZEN_DESK=$(arch-chroot /mnt bash -c 'ls /usr/share/applications/*zen*.desktop 2>/dev/null | head -n1')
if [ -n "$ZEN_DESK" ]; then
  ZEN_BASE=$(basename "$ZEN_DESK")
  arch-chroot /mnt sudo -u "$USERN" xdg-settings set default-web-browser "$ZEN_BASE" 2>/dev/null || true
  mkdir -p /mnt/home/"$USERN"/.config
  printf '[Default Applications]\ntext/html=%s\nx-scheme-handler/http=%s\nx-scheme-handler/https=%s\n' "$ZEN_BASE" "$ZEN_BASE" "$ZEN_BASE" > /mnt/home/"$USERN"/.config/mimeapps.list
  arch-chroot /mnt chown "$USERN:$USERN" /home/"$USERN"/.config/mimeapps.list 2>/dev/null || true
fi
arch-chroot /mnt bash -c "pacman -S --noconfirm freetype2-macos" 2>/dev/null || echo "macOS-like freetype skipped, stock stack already tuned"
arch-chroot /mnt bash -c "pacman -S --noconfirm aide && mkdir -p /var/lib/aide && aide --init && mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz" 2>/dev/null || echo "aide skipped, KZC hashing still covers persist paths"

# target needs the same repos or its kernel never updates
grep -q "^\[cachyos\]" /mnt/etc/pacman.conf || printf '\n[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n' >> /mnt/etc/pacman.conf
cp /etc/pacman.d/cachyos-mirrorlist /mnt/etc/pacman.d/ 2>/dev/null || true
genfstab -U /mnt >> /mnt/etc/fstab
UUID=$(blkid -s UUID -o value "$ROOT")
cp -r airootfs/* /mnt/ || true
for g in wheel video audio seat libvirt kvm; do
  arch-chroot /mnt groupadd -f "$g"
done
arch-chroot /mnt useradd -m -G wheel,video,audio,seat,libvirt,kvm -s /bin/zsh "$USERN"
echo "Set an initial login PIN for $USERN (replaced by key auth after setup):"
arch-chroot /mnt passwd "$USERN"
echo '%wheel ALL=(ALL:ALL) ALL' > /mnt/etc/sudoers.d/wheel
chmod 440 /mnt/etc/sudoers.d/wheel
cp -rn /mnt/etc/skel/. /mnt/home/"$USERN"/ 2>/dev/null || true
arch-chroot /mnt chown -R "$USERN:$USERN" /home/"$USERN" 2>/dev/null || true
arch-chroot /mnt fc-cache -f >/dev/null 2>&1 || true
echo "LANG=C.UTF-8" > /mnt/etc/locale.conf
echo "$HOSTN" > /mnt/etc/hostname
ln -sf /usr/share/zoneinfo/UTC /mnt/etc/localtime
arch-chroot /mnt mkinitcpio -P
arch-chroot /mnt bootctl install --esp-path=/boot
CMDLINE="root=/dev/mapper/lamxroot rw rootflags=subvol=@ rd.luks.name=$UUID=lamxroot quiet loglevel=3 systemd.show_status=auto preempt=full mem_sleep_default=deep lockdown=confidentiality slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 vsyscall=none debugfs=off"
cat > /mnt/boot/loader/entries/lamx.conf <<EOF
title lamX
linux /vmlinuz-linux-cachyos-hardened
initrd /intel-ucode.img
initrd /amd-ucode.img
initrd /initramfs-linux-cachyos-hardened.img
options $CMDLINE mitigations=auto nowatchdog
EOF
cat > /mnt/boot/loader/entries/lamx-unleashed.conf <<EOF
title lamX unleashed (no CPU mitigations, less secure)
linux /vmlinuz-linux-cachyos-hardened
initrd /intel-ucode.img
initrd /amd-ucode.img
initrd /initramfs-linux-cachyos-hardened.img
options $CMDLINE mitigations=off nowatchdog
EOF
echo "default lamx.conf
timeout 3" > /mnt/boot/loader/loader.conf
arch-chroot /mnt systemctl enable NetworkManager seatd greetd apparmor chronyd power-profiles-daemon systemd-resolved systemd-oomd auditd kzc-monitor kzc-head opencode-kzc lamx-firstboot thermald ananicy-cpp snapper-timeline.timer snapper-cleanup.timer fstrim.timer plocate-updatedb.timer libvirtd "syncthing@$USERN" fwupd-refresh.timer kzc-aide.timer
arch-chroot /mnt systemctl mask bluetooth NetworkManager-wait-online.service
arch-chroot /mnt systemctl --global enable kzc-digest.timer
echo "Enroll TPM2+PIN now:"
systemd-cryptenroll --tpm2-device=auto --tpm2-with-pin=yes --tpm2-pcrs=0+7 "$ROOT" || true
echo "lamX installed. Boot menu holds lamX and lamX unleashed. Then run lamx-firstboot as $USERN."
