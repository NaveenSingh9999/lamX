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

pacstrap -K /mnt base linux-cachyos-hardened linux-firmware intel-ucode amd-ucode \
  sway swaylock swayidle hyprland hyprpaper xdg-desktop-portal-hyprland waybar wofi foot mako swaybg greetd greetd-tuigreet seatd polkit \
  ttf-jetbrains-mono-nerd ttf-dejavu iptables pipewire-jack pipewire-alsa crun \
  networkmanager iwd pipewire pipewire-pulse wireplumber power-profiles-daemon \
  yazi neovim git curl fastfetch apparmor bubblewrap chrony openssh \
  tpm2-tss libfido2 pam-u2f oath-toolkit \
  audit bpftrace python libnotify polkit polkit-gnome \
  qemu-desktop quickemu virt-manager libvirt edk2-ovmf swtpm dnsmasq bridge-utils
# extras post-install via chaotic-aur: swayfx glassy, blur lock, opencode head
arch-chroot /mnt bash -c "pacman-key --recv-keys 3056513887B78AEB --keyserver keyserver.ubuntu.com && pacman-key --lsign-key 3056513887B78AEB && pacman -U --noconfirm https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst && echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf && pacman -Sy --noconfirm && pacman -S --noconfirm swayfx swaylock-effects opencode-bin && /usr/local/bin/lamx-glassy on" || echo "extras skipped, install manually later"

genfstab -U /mnt >> /mnt/etc/fstab
UUID=$(blkid -s UUID -o value "$ROOT")
echo "lamxroot UUID=$UUID none tpm2-device=auto" > /mnt/etc/crypttab.initramfs
arch-chroot /mnt useradd -m -G wheel,video,audio,seat,libvirt,kvm -s /bin/bash "$USERN"
echo "$HOSTN" > /mnt/etc/hostname
ln -sf /usr/share/zoneinfo/UTC /mnt/etc/localtime
arch-chroot /mnt systemctl enable NetworkManager seatd greetd apparmor chronyd power-profiles-daemon systemd-resolved auditd kzc-monitor kzc-notify opencode-kzc lamx-firstboot thermald tlp snapper-timeline.timer snapper-cleanup.timer libvirtd
arch-chroot /mnt systemctl mask bluetooth
echo "Enroll TPM2+PIN now:"
systemd-cryptenroll --tpm2-device=auto --tpm2-with-pin=yes --tpm2-pcrs=0+7 "$ROOT" || true
cp -r airootfs/* /mnt/ || true
echo "lamX installed. Reboot, then run lamx-firstboot as $USERN."
