# lamX

Ultra-light, Arch-based daily driver for people who live in the terminal but want a beautiful desktop on demand.

Base: **CachyOS (Arch-compatible, x86_64)** · Compositor: **Sway / SwayFX glass** · Design: **CLI-first, GUI on demand** · Security: **on-device KZC, passwordless TPM + phone key**

> Private by design. The running device shows no branding, no OS name in login banners or MOTD. What you see here is the build source.

---

## Why lamX

- **Ultra-light:** minimal package set, Sway + Waybar + Wofi + Foot, zram, no full desktop environment.
- **Daily-driver ready:** WiFi, Bluetooth stack, camera, all-vendor GPU (AMD / Intel / Nvidia open), audio via PipeWire, power profiles, laptop battery tuning.
- **Glassy UI:** transparent Waybar, Wofi launcher, Foot terminal, Mako notifications. Full blur, rounded corners, and shadows unlock automatically when SwayFX is installed post-boot.
- **Hardware killswitches:** `lamx disable camera|wifi|bluetooth|mic|speakers|usb|ethernet|nvidia` blocks at kernel level instantly — module removal, USB unbind, rfkill, persistent blacklist. No reboot needed.
- **Passwordless:** TPM2 + short PIN for disk, phone as FIDO2 key plus TOTP backup via Aegis, physical FIDO2 key enrolls later with one command. No long passwords.
- **Access prompts:** Polkit agent in Sway shows a system prompt for restricted actions, approved by key touch. `lamx-prompt <cmd>` for terminal.
- **KZC security:** on-device statistical AI monitor (no LLM, no network, no API) watches processes, kernel modules, persist paths, and USB. Auto kill on shell escape, auto quarantine, one notification. Open-source stack: auditd, AppArmor, AIDE-style hashing, bpftrace. Runs 24/7, refuses manual stop. An `opencode` head agent triages alerts locally.
- **Safe updates:** Btrfs + Snapper timelines, encrypted backups, secure wipe, offline recovery keys.

---

## Releases

**Latest ISO:** see [Releases](../../releases). Each release publishes `lamX-<date>-x86_64.iso` built by GitHub Actions from `profile/`.

> First release `v0.1.0` is promoted from the Actions artifact `lamX-iso`. If the ISO exceeds the release asset limit it is split automatically — see release notes.

Verify after download:

```bash
sha256sum lamX-*.iso
```

---

## Install — complete commands

You need: x86_64 laptop, UEFI, 4 GB USB, internet. **This wipes the target disk.**

### 1. Flash the ISO

```bash
# find your USB (check carefully, e.g. /dev/sdb)
lsblk

# flash (replace /dev/sdX and the ISO name)
sudo dd if=lamX-2026.09.06-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Boot the USB in UEFI mode.

### 2. Connect network in the live session

```bash
nmtui
# or
nmcli device wifi list
nmcli device wifi connect "SSID" password "PASS"
```

### 3. Run the installer

```bash
# list disks first
lsblk

# install (replace /dev/nvme0n1 with your disk, username optional, default lamx)
sudo ./scripts/install.sh /dev/nvme0n1 lamx
```

What it does: GPT + ESP + LUKS2 root, Btrfs `@` and `@home` with zstd, pacstrap base + Sway + drivers, single user, enables NetworkManager, seatd, greetd, AppArmor, KZC, time sync, masks Bluetooth, enrolls TPM2+PIN, copies all configs.

When asked, set your LUKS PIN-backed passphrase once. Reboot, remove USB.

### 4. First-time setup wizard

On first boot, as your user:

```bash
sudo lamx-setup
```

Walks through: timezone, keyboard, device name, TOTP secret with QR for Aegis on your phone, phone FIDO2 enroll via USB, WiFi, initial Snapper snapshot, KZC check. Runs once, then disables itself.

Quick help anytime:

```bash
lamx-help
```

### 5. Passwordless keys

```bash
# phone as key now (connect via USB, approve on phone)
pamu2fcfg -u lamx >> /etc/pam-u2f/authfile

# hardware key later, same command with key inserted
pamu2fcfg -u lamx >> /etc/pam-u2f/authfile

# show TOTP backup URI again if needed
sudo cat /etc/users.oath
```

Boot uses PIN + TPM. Lock screen and sudo use key touch, fallback PIN + Aegis code.

### 6. Full glassy UI (blur) on target

The ISO ships vanilla Sway so it builds everywhere. On your laptop, enable full SwayFX blur:

```bash
# extras install swayfx, blur lock, and opencode head from chaotic-aur
# (already attempted by installer, rerun if offline during install)
sudo lamx-glassy on
```

Then restart Sway. If `swayfx` is unavailable for your mirror, the transparent Waybar/Wofi/Foot theme still applies without compositor blur.

### 7. VPN killswitch (optional, off by default)

```bash
sudo cp /etc/wireguard/wg0.conf.example /etc/wireguard/wg0.conf
sudoedit /etc/wireguard/wg0.conf   # fill PrivateKey, PublicKey, Endpoint
lamx-vpn on      # only wg0 + lo allowed
lamx-vpn status
lamx-vpn off
```

### 8. Backups, snapshots, recovery

```bash
# snapshot before risky changes
sudo snapper -c root create --description "before-test"

# encrypted backup to USB or phone storage
sudo lamx-backup /mnt/backup

# show LUKS slots and TPM status for paper backup
sudo ./scripts/recovery-key.sh /dev/nvme0n1p2

# secure erase a disk (asks ERASE)
sudo lamx-wipe /dev/nvme0n1
```

---

## Daily use

```bash
lamx list                        # hardware states + devices + modules
sudo lamx disable camera         # instant kernel-level block, persists
sudo lamx enable camera
lamx-prompt systemctl restart NetworkManager   # GUI-equivalent approval prompt
lamx-vpn on
lamx-backup /mnt/backup
```

Sway keys: `Mod+Enter` terminal, `Mod+D` launcher, `Mod+Shift+E` exit. Auto-lock after 60 seconds, screen off after 5 minutes.

Dev isolation without polluting base:

```bash
distrobox create -i archlinux:latest -n dev
distrobox enter dev
```

---

## Build from source

```bash
git clone https://github.com/NaveenSingh9999/lamX.git
cd lamX

# option A: GitHub Codespaces (recommended)
# open repo in Codespaces, then:
./scripts/build.sh
ls out/

# option B: local Arch/x86_64 with v3 support
sudo pacman -S --needed archiso git base-devel
./scripts/build.sh

# option C: GitHub Actions
gh workflow run build-iso --repo NaveenSingh9999/lamX
```

ISO appears in `out/` or as the `lamX-iso` artifact. The ISO uses generic CachyOS repos so it builds on runners without x86-64-v3. After install, switch to optimized repos on your laptop:

```bash
sudo ./cachyos-repo.sh   # from cachyos-repo.tar.xz, picks v3/v4/znver4 automatically
```

---

## Repo layout

```text
profile/                 archiso profile (packages, pacman.conf, bootloaders)
airootfs/                overlay: sway, waybar, wofi, foot, mako, greetd,
                         sysctl hardening, MAC randomization, DNS-over-TLS,
                         polkit rules, KZC, opencode head, lamx tools
scripts/                 build.sh, install.sh, enroll-fido.sh, recovery-key.sh
.devcontainer/           Codespaces Arch build environment
.github/workflows/      build-iso.yml, promote-release.yml
```

Key tools in the installed system: `lamx`, `lamx-prompt`, `lamx-vpn`, `lamx-backup`, `lamx-wipe`, `lamx-help`, `lamx-setup`, `lamx-glassy`, `kzc-monitor`, `kzc-notify`.

---

## Security model

- Single user, no guest, root login disabled, greetd autologin only after LUKS decrypt proves identity.
- LUKS2 + TPM2 + PIN now, FIDO2 enroll anytime. Swaylock + sudo via `pam_u2f` then `pam_oath`.
- Kernel: hardened kernel, AppArmor enforce, `lockdown`, disabled kexec, restricted dmesg and ptrace, no core dumps.
- KZC monitor learns exec baselines and z-scores anomalies locally, quarantines new persist scripts, kills GUI-spawned shells, alerts once.
- No Secure Boot and no incoming firewall by device-owner choice. Bootkit and network exposure risk is higher — disk, OS, and data layers remain enforced.

---

## Status

Working ISO builds in CI (~21 min). Tested: profile validation, package install, squashfs, artifact upload. Pending: VM boot test matrix and hardware test on target laptop.

Issues and ideas welcome. This is a personal build made public for showcase — device runtime stays identifier-free by design.
