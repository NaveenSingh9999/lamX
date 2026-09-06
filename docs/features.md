# Features

<img src="../airootfs/usr/share/icons/lamX.png" width="128" alt="lamX mark">

## Base

CachyOS hardened kernel on vanilla Arch userland, x86_64, systemd. Intel-only ISO keeps downloads small. AMD and Nvidia arrive through the setup GPU chooser. Btrfs with zstd plus Snapper timelines, zram, single power stack, quiet fast boot with no network wait.

## Desktop

Sway by default for battery, Hyprland session for bezier animations. Transparent Waybar, Wofi, Foot, Mako. SwayFX blur unlocks post-install. Spotlight on Mod+Space, music on Mod+M, media keys everywhere. Hex mark shows in fetch output.

## Audio and music

PipeWire at 48kHz with 256 quantum, realtime priority and locked memory for audio threads. ytfzf plus mpv streams YouTube audio with queue and subscriptions, no accounts, themed OSD.

## Hardware control

Kernel-level killswitches per component with persistent blacklists, instant and reboot-free. GUI polkit prompts plus terminal equivalent. WireGuard killswitch optional.

## Security

LUKS2 plus TPM2 plus PIN, phone as FIDO2 key with TOTP fallback, hardware key later. Single user, hardened kernel with lockdown and allocator defenses, AppArmor, audit rules, sysctl set. KZC v2 scores exec anomalies with decay and allowlist, quarantines persist tricks with restore, alerts once, runs always, refuses manual stop. Local dashboard plus CLI. No Secure Boot and no incoming firewall by owner choice — documented tradeoff.

## Data and devices

Encrypted snapshot backups, secure wipe, paper recovery keys, SSH phone link, Syncthing pairing, Wake-on-LAN, QEMU stack with UEFI and TPM for testing, Distrobox dev isolation.

## Operations

One-command installer with correct bootloader entries including an unleashed no-mitigations option, first-boot wizard, rented-VM converter that never wipes, manual cloud builds on tags to save hours, releases with checksums.
