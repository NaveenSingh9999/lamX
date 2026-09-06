# lamX

<img src="airootfs/usr/share/icons/lamX.png" width="128" alt="lamX mark">

Ultra-light, Arch-based daily driver for people who live in the terminal but want a beautiful desktop on demand.

Base: **CachyOS hardened (Arch-compatible, x86_64)** · Sessions: **Sway default, Hyprland for animations** · Design: **CLI-first, GUI on demand** · Security: **on-device KZC, passwordless TPM + phone key**

> Private by design. The running device shows no branding in login banners or MOTD.

## Docs

- [Docs index](docs/README.md)
- [Complete setup](docs/setup.md) — flash, install, wizard, keys, GPU, glassy UI
- [Sessions](docs/sessions.md) — GUI and TUI switching, Sway vs Hyprland, lock
- [Command reference](docs/commands.md) — every `lamx-*` tool and how to run it
- [Features](docs/features.md) — full tour with reasoning

## Quickstart

```bash
sudo dd if=lamX-<date>-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Boot USB in UEFI, run `nmtui`, then:

```bash
sudo ./scripts/install.sh /dev/nvme0n1 lamx
```

Reboot, then `sudo lamx-setup`, then `lamx-help`. Full walkthrough in [setup](docs/setup.md).

Rented Arch VM without wiping: `sudo ./scripts/convert-arch.sh`. Never run `install.sh` there.

## Graphics and hardware acceleration

One ISO boots every x86_64 machine. Both CPU microcodes ship natively, generic Mesa covers display out of the box, and the setup chooser installs your full stack or skips it.

| GPU | Stack | Acceleration |
|---|---|---|
| <img src="https://cdn.simpleicons.org/intel/0068B5" width="20" alt="Intel"> Intel | Pre-installed: Mesa, Vulkan-Intel, Intel media driver, EGL Wayland | VA-API decode and encode, Vulkan |
| <img src="https://cdn.simpleicons.org/amd/ED1C24" width="20" alt="AMD"> AMD | Chooser installs: Vulkan-Radeon, Mesa VA-API and VDPAU, amdgpu and ATI Xorg | VA-API, VDPAU, Vulkan |
| <img src="https://cdn.simpleicons.org/nvidia/76B900" width="20" alt="Nvidia"> Nvidia | Chooser installs: open DKMS driver, utils, VA-API over NVDEC | NVDEC decode, Vulkan, Wayland via EGL |
| VM | Chooser installs: spice-vdagent, guest agent, QXL | Paravirtual display |

Media apps use it automatically: mpv hardware decode, PipeWire camera plugins, Hyprland and SwayFX GPU compositing.

## Minimum requirements

Estimated from the package set, measured boot plus desktop before release will confirm.

| | Minimum | Recommended |
|---|---|---|
| CPU | Any 64-bit x86, 2 cores, Intel or AMD | 2015 or newer for v3 optimized repos |
| RAM | 2 GB to boot live | 4 GB Sway daily, 8 GB Hyprland plus browser |
| Disk | 12 GB install | 25 GB plus room for Snapper timelines |
| Boot | UEFI | UEFI plus TPM 2.0 for passwordless disk |
| Network | Needed once for install | Always on for updates and sync |

## Releases

See [Releases](../../releases) for the ISO plus SHA256SUMS. Verify with `sha256sum`.

## Build

Manual or tag builds only, to save Actions hours:

```bash
./scripts/build.sh        # Codespaces or local Arch x86_64, output in out/
gh workflow run build-iso # cloud build, ~20 min
```

Generic CachyOS repos build on any x86_64 runner. Switch to v3 or v4 repos on your laptop afterwards.

## Layout

```text
profile/                 archiso profile, hardened quiet boot cmdline
airootfs/                full system overlay, see docs for contents
scripts/                 build, install, convert-arch, enroll-fido, recovery-key
docs/                    setup, sessions, commands, features
.devcontainer/           Codespaces build environment
.github/workflows/      build-iso (manual plus tags), promote-release
```

## Status

v0.1.0 released. Since then: lean all-CPU base, GPU chooser with full vendor stacks, music stack, spotlight, hex icon, kernel round two, KZC v2 plus dashboard, phone link, quiet boot, xtreme mode, QEMU stack. Next release after VM boot validation.
