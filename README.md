# lamX

<img src="profile/airootfs/usr/share/icons/lamX.png" width="128" alt="lamX mark">

**Ultra-light, Arch-based daily driver for people who live in the terminal but want a beautiful desktop on demand.**

Base: **CachyOS hardened (Arch-compatible, x86_64)** · Sessions: **Sway default, Hyprland for animations** · Design: **CLI-first, GUI on demand** · Security: **on-device KZC, passwordless TPM + phone key**

> Private by design. Pre-login screens carry no OS advertising. The mark appears only where you invoke it.

---

## Contents

- [Docs](docs/README.md) — index of all guides
- [Features](#features) · [Graphics](#graphics-and-hardware-acceleration) · [Requirements](#minimum-requirements)
- [Install](#install) · [Daily use](#daily-use) · [Build](#build-from-source) · [Test](#test)
- [Security model](#security-model) · [Releases](#releases) · [Status](#status)

---

## Features

| Area | What you get |
|---|---|
| **Base** | CachyOS hardened kernel, Arch userland, systemd, Btrfs with zstd plus Snapper timelines, zram, quiet fast boot, no network wait |
| **Desktop** | Sway keychord modes plus app-pinned workspaces, Hyprland fluent bounce motion, transparent Waybar, Wofi, Foot, Mako, eww center clock, live video wallpaper with still fallback |
| **Display** | Max resolution plus max refresh auto-set every login, adaptive sync and VRR, 1080p fallback, wlr-randr for changes |
| **Lock** | hyprlock face with lamX mark over blur and clock, swaylock-effects face with screenshot blur and date, one lamx-lock entry |
| **Search** | Spotlight on Mod+Space: calc, instant file index, music, web, apps |
| **Music** | ytfzf plus mpv streaming from YouTube, no accounts, realtime audio path, media keys everywhere |
| **Text** | Apple-grade rendering preset, IosevkaTerm Nerd Font throughout, zsh with autosuggest plus highlighting plus Pure prompt |
| **Hardware** | Kernel killswitches per component including full internet cut, polkit approval prompts, WireGuard killswitch |
| **Privacy** | Mic, camera, and casting indicators in bar and terminal, DNS adblock toggle, Tor-style VPN option |
| **Power** | Xtreme max-limits mode, phone-style idle sip mode with auto switching, oomd plus auto priorities |
| **Data** | Encrypted snapshot backups, secure wipe, paper recovery keys, SSH phone link, Syncthing pairing, Wake-on-LAN |
| **Dev** | Distrobox isolation, Podman, man pages, completions, QEMU stack one command away |
| **VMs** | Quickemu for instant ISO tests, virt-manager full GUI, both one command away post-install |

Desktop styling ships through the installer, never bloating the ISO. Sway structure follows bibjaw99/workstation, Hyprland motion follows nv8v/workstation, apps and colors stay lamX.

---

## Graphics and hardware acceleration

One ISO boots every x86_64 machine. Both CPU microcodes ship natively, generic Mesa covers display out of the box, every output jumps to its max mode and refresh at login, and the setup chooser installs your full stack or skips it.

| GPU | Stack | Acceleration |
|---|---|---|
| <img src="https://cdn.simpleicons.org/intel/0068B5" width="20" alt="Intel"> Intel | Pre-installed: Mesa, Vulkan-Intel, Intel media driver, EGL Wayland | VA-API decode and encode, Vulkan |
| <img src="https://cdn.simpleicons.org/amd/ED1C24" width="20" alt="AMD"> AMD | Chooser installs: Vulkan-Radeon, Mesa VA-API and VDPAU, amdgpu and ATI Xorg | VA-API, VDPAU, Vulkan |
| <img src="https://cdn.simpleicons.org/nvidia/76B900" width="20" alt="Nvidia"> Nvidia | Chooser installs: open DKMS driver, utils, VA-API over NVDEC | NVDEC decode, Vulkan, Wayland via EGL |
| VM | Chooser installs: spice-vdagent, guest agent, QXL | Paravirtual display |

Media apps use it automatically: mpv hardware decode, PipeWire camera plugins, Hyprland and SwayFX GPU compositing.

---

## Minimum requirements

Estimated from the package set. Measured boot plus desktop numbers land after hardware validation.

| | Minimum | Recommended |
|---|---|---|
| CPU | Any 64-bit x86, 2 cores, Intel or AMD | 2015 or newer for v3 optimized repos |
| RAM | 2 GB to boot live | 4 GB Sway daily, 8 GB Hyprland plus browser |
| Disk | 12 GB install | 25 GB plus room for Snapper timelines |
| Boot | UEFI or BIOS | UEFI plus TPM 2.0 for passwordless disk |
| Network | Needed once for install | Always on for updates and sync |

---

## Install

You need an x86_64 laptop, UEFI or BIOS boot, a 4 GB USB stick, and internet. **The installer wipes the target disk.**

### 1. Flash

```bash
lsblk   # identify the USB stick, triple check
sudo dd if=lamX-<date>-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### 2. Network, then install

```bash
nmtui
lsblk   # identify the target disk
sudo ./scripts/install.sh /dev/nvme0n1 lamx
```

The installer partitions, encrypts with LUKS2, lays Btrfs subvolumes, installs the full set, writes both boot entries (`lamX` default, `lamX unleashed` without CPU mitigations), enables every service, enrolls TPM2 plus PIN, and asks for an initial login PIN. Root carries the same PIN hash for emergency recovery.

### 3. First boot

```bash
sudo lamx-setup
```

Timezone, keyboard, device name, TOTP QR for Aegis, phone FIDO enroll, WiFi, GPU chooser, live wallpaper fetch, speed-versus-armor question, snapshot baseline, KZC check. Runs once.

```bash
lamx-help   # every command, anytime
```

Rented Arch VM instead of bare metal:

```bash
sudo ./scripts/convert-arch.sh   # converts without wiping, never run install.sh there
```

Full walkthrough: [Complete setup](docs/setup.md).

---

## Daily use

```bash
lamx list | sudo lamx disable camera | sudo lamx enable camera
lamx-prompt systemctl restart NetworkManager
music [terms] | music -q [terms] | music -s
lamx-kzc status | suspects | logs          # security at a glance
kzc-dashboard                              # local GUI in browser
lamx-phone link user@phone-ip              # then push, pull, notify, status
lamx-vpn on | lamx-backup /mnt/backup
sudo lamx-xtreme on | sudo lamx-idle on
lamx-wallpaper | lamx-display              # refresh loop or max out displays
```

Keys match in both sessions: `Mod+Enter` terminal, `Mod+D` launcher, `Mod+Space` spotlight, `Mod+M` music, `Mod+Shift+E` power menu, `Print` screenshot. Auto-lock after 60 seconds.

Full reference: [Commands](docs/commands.md). Sessions and switching: [Sessions](docs/sessions.md). Security design: [KZC](docs/kzc.md).

---

## Build from source

Manual or tag builds only, to save Actions hours.

```bash
git clone https://github.com/NaveenSingh9999/lamX.git
cd lamX
./scripts/build.sh        # Codespaces or local Arch x86_64, output in out/
gh workflow run build-iso # cloud build, roughly 20 minutes
```

The ISO initramfs gets live hooks through a post-build repack that preserves the boot record, verified in CI. Generic CachyOS repos build on any x86_64 runner. Switch to v3 or v4 repos on your laptop afterwards for speed.

---

## Test

Every ISO boots headless in QEMU before release:

```bash
gh workflow run boot-test --repo NaveenSingh9999/lamX -f run_id=<build-id>
```

Serial console proves media mount plus full userspace plus the lamX banner. For interactive testing in Codespaces with a browser display:

```bash
./scripts/codespace-vm.sh ~/lamX-<date>-x86_64.iso vnc   # browser via port 6080
./scripts/codespace-vm.sh ~/lamX-<date>-x86_64.iso term  # serial in this terminal
```

Privileged container plus KVM gives host CPU speed, emulation otherwise. Codespaces arrive with the release ISO pre-fetched.

---

## Security model

Single user, root login disabled on installed targets with PIN hash kept for emergency recovery, live media root open by design, console login only after LUKS decrypt. Hardened kernel with lockdown confidentiality, slab and allocator defenses, quiet hardened cmdline. AppArmor enforce, audit rules on identity, privilege, modules, persist paths. KZC scores anomalies locally with decay and allowlist, quarantines with restore, warns, asks, acts through its head daemon, alerts once. No Secure Boot and no incoming firewall by owner choice.

---

## Releases

See [Releases](../../releases) for ISOs plus SHA256SUMS plus the live wallpaper loop. Verify with `sha256sum`.

---

## Repo layout

```text
profile/                 archiso profile, hardened quiet boot cmdline
profile/airootfs/        live system overlay
scripts/                 build, repack, install, convert-arch, apply-desktop,
                         enroll-fido, recovery-key, codespace-vm
docs/                    setup, sessions, commands, features, kzc
assets/                  release-hosted extras like the wallpaper loop
.devcontainer/           codespaces default plus arch build env
.github/workflows/      build-iso (manual plus tags), boot-test, promote-release
```

---

## Status

v1.6 released and boot-proven in CI. Current build carries the desktop applier, max display setup, branded lock faces, and wallpaper auto-fetch. Hardware validation continues on real machines.
