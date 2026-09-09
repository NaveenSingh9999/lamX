# Features

<img src="../profile/airootfs/usr/share/icons/lamX.png" width="128" alt="lamX mark">

## Base

CachyOS hardened kernel on vanilla Arch userland, x86_64, systemd. Lean base boots Intel and AMD CPUs out of the box, GPU vendor stacks install through the setup chooser. Btrfs with zstd plus Snapper timelines, zram, single power stack, quiet fast boot with no network wait.

## Desktop

XFCE desktop with dark theme and Pebble-Slate icons, IosevkaTerm terminal with starship prompt, rofi spotlight on Super+Space, music on Super+M, media keys everywhere. Hex mark shows in fetch output. Hyprland or Sway can be layered later from the terminal.

## Audio and music

PipeWire at 48kHz with 256 quantum, realtime priority and locked memory for audio threads. ytfzf plus mpv streams YouTube audio with queue and subscriptions, no accounts, themed OSD.

## Hardware control

Kernel-level killswitches per component with persistent blacklists, instant and reboot-free. GUI polkit prompts plus terminal equivalent. WireGuard killswitch optional.

## Security

LUKS2 plus TPM2 plus PIN, phone as FIDO2 key with TOTP fallback, hardware key later. Single user, hardened kernel with lockdown and allocator defenses, AppArmor, audit rules, sysctl set. KZC v2 scores exec anomalies with decay and allowlist, quarantines persist tricks with restore, alerts once, runs always, refuses manual stop. Local dashboard plus CLI. No Secure Boot and no incoming firewall by owner choice — documented tradeoff.

## Data and devices

Encrypted snapshot backups, secure wipe, paper recovery keys, SSH phone link, Syncthing pairing, Wake-on-LAN, QEMU stack with UEFI and TPM one command away, Distrobox dev isolation post-install.

## Operations

One-command installer with correct bootloader entries including an unleashed no-mitigations option, first-boot wizard, rented-VM converter that never wipes, manual cloud builds on tags to save hours, releases with checksums.
