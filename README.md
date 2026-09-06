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

v0.1.0 released. Since then: stripped Intel-only base, GPU chooser, music stack, spotlight, hex icon, kernel round two, KZC v2 plus dashboard, phone link, quiet boot, xtreme mode, QEMU stack. Next release after VM boot validation.
