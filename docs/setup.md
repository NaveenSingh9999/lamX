# Complete setup

## 1. Flash

```bash
lsblk   # identify USB, e.g. /dev/sdb — triple check, dd destroys data
sudo dd if=lamX-<date>-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Boot the USB in UEFI mode. Boot is quiet with status only.

## 2. Network in live session

```bash
nmtui
```

## 3. Install — wipes the target disk

```bash
lsblk
sudo ./scripts/install.sh /dev/nvme0n1 lamx
```

What happens: GPT with ESP plus LUKS2 root, Btrfs `@` and `@home` with zstd, pacstrap of the lean all-CPU base, single user in wheel video audio seat libvirt kvm with zsh, tuned initramfs regenerated, systemd-boot with two entries (`lamX` default, `lamX unleashed` without CPU mitigations), services enabled, Bluetooth and boot network-wait masked, TPM2 plus PIN enrolled, initial login PIN set, wheel sudo enabled.

Type your LUKS passphrase once when asked.

## 4. First boot wizard

```bash
sudo lamx-setup
```

Steps: timezone, keyboard, neutral device name, TOTP secret shown as QR for Aegis, phone FIDO2 enroll over USB, WiFi, **GPU chooser** (Intel already in, AMD installs vulkan-radeon, Nvidia installs open DKMS, VM installs guest agents, Skip stays minimal), speed-versus-armor question for unleashed-by-default, snapshot baseline, KZC check. Runs once, then disables itself.

## 5. Keys

```bash
pamu2fcfg -u lamx >> /etc/pam-u2f/authfile   # phone now, hardware key later the same way
```

Boot: PIN plus TPM. Lock and sudo: key touch, fallback PIN plus Aegis code.

## 6. Full glassy UI

The ISO ships vanilla Sway so it builds and boots everywhere. On your machine:

```bash
sudo lamx-glassy on   # after swayfx lands via extras install, then restart Sway
```

Pick Sway for battery or Hyprland for animations at login. Details in [sessions](sessions.md).

## 7. Verify the install

```bash
lamx-help
lamx list
systemctl is-active kzc-monitor kzc-head auditd
fastfetch   # shows the lamX mark
```

## 8. Optional next steps

- VPN killswitch: copy `wg0.conf.example`, fill keys, `lamx-vpn on`.
- Phone: `lamx-phone link user@ip`, Syncthing pair via `lamx-sync ui`.
- Backup: `lamx-backup /mnt/backup`. Paper keys: `recovery-key.sh`.
- Rented Arch VM instead of bare metal: `sudo ./scripts/convert-arch.sh` converts without wiping. Never run `install.sh` there.
