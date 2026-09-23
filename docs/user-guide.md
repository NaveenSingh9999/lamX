# lamX user guide — commands you will actually need

## Session

SDDM astronaut login with Jake. Caelestia shell first, XFCE second. Switch sessions from the login menu, no reinstall.

## Network

```bash
nmtui                        # wifi and connections
nmcli device wifi list       # scan from terminal
lamx-vpn on | off | status   # WireGuard killswitch, config wg0 first
```

## Hardware killswitches

```bash
lamx list
sudo lamx disable camera     # camera wifi bluetooth mic speakers usb ethernet nvidia internet
sudo lamx enable camera
```

## Files and backup

```bash
yazi                         # file manager
lamx-backup /mnt/backup      # encrypted snapshot backup
sudo lamx-wipe /dev/sdX      # secure erase, asks ERASE
snapper -c root list         # snapshots
sudo snapper -c root undochange 1..0   # rollback one snapshot
```

## Music and look

```bash
music lofi girl              # stream, -q queues, -s subscriptions
lamx-wallpaper               # reselect loop or still
lamx-wallpaper-fetch <url>   # add open loops
```

## Security

```bash
lamx-kzc status | suspects | logs | decisions
lamx-kzc allow 'foot>bash' | restore
kzc-dashboard                # local GUI
lamx-eye | lamx-eye --watch  # mic camera casting indicators
lamx-adblock on | off        # resolver blocking
```

## Power and speed

```bash
sudo lamx-xtreme on | off    # max limits, AC only
sudo lamx-idle on | off      # sip mode, auto arms on unplug
```

## Phone and sync

```bash
lamx-phone link user@ip      # then push pull notify status
lamx-sync status | ui        # syncthing panel, pair by device ID
```

## System

```bash
sudo lamx-setup              # rerun wizard, re-shows TOTP QR
sudo apply-desktop.sh        # reapply theme
lamx-help                    # condensed list on device
fastfetch                    # lamX mark plus specs
```

## Recovery

Lost keys: boot live ISO, unlock LUKS by passphrase, mount root, `arch-chroot` and `passwd lamx`. Paper backup from `scripts/recovery-key.sh` avoids all of this.
