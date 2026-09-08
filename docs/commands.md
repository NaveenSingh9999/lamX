# Command reference

Every tool ships on PATH. Anything touching hardware or security needs sudo.

## lamx — kernel hardware killswitch

`lamx list` shows components with active or disabled state, device nodes, rfkill, loaded modules. `sudo lamx disable <camera|wifi|bluetooth|mic|speakers|usb|ethernet|nvidia>` unbinds drivers, removes modules, writes persistent blacklists. Instant, no reboot. `sudo lamx enable <component>` reverses it.

## lamx-prompt — approval prompt

`lamx-prompt <command>` runs one restricted command through Polkit, which pops the system approval dialog using your key auth. The GUI equivalent of sudo without a terminal password.

## lamx-spotlight — themed search

Mod+Space. Prefixes: `=2+2` calculates, `/term` finds files with fd, `@term` streams music matches, `?term` opens web search, plain text launches apps and commands. Wofi only, glassy theme inherited.

## lamx-music — streaming player

`music [terms]` searches and plays YouTube audio via ytfzf plus mpv, no accounts. `-q` queues, `-s` opens subscriptions. Audio runs through PipeWire realtime priority with locked memory and a 256 low-latency quantum. Mod+M opens it.

## lamx-kzc — security control

`status` shows service states, learned samples, suspect and quarantine counts. `suspects` ranks exec anomalies by score. `allow 'parent>child'` adds an allowlist entry live. `restore [match]` brings back quarantined files. `logs [n]` tails alerts. `quarantine` lists held files.

## kzc-dashboard — security GUI

Local-only web UI on loopback, opened in the browser with one command. Live service status, suspect table with one-click allow, quarantine with one-click restore, recent alerts, full config view. Also in the app launcher as Security Dashboard.

## lamx-vpn — Tor-style killswitch for WireGuard

`on` brings up wg0 and drops all output except tunnel plus loopback. `off` restores. `status` shows both. Off by default. Configure from `wg0.conf.example` first.

## lamx-sync — Syncthing plus Wake-on-LAN

`status` checks daemon and local API. `ui` opens the 127.0.0.1:8384 panel to pair the phone app by device ID. `pause` and `resume` control syncing. `wake <mac>` sends a magic packet, `wol-check` verifies the NIC. Wired plus BIOS WoL required for wake.

## lamx-phone — phone over SSH

`link user@ip` exchanges keys. `status` reads battery and uptime. `push` and `pull` move files through `~/lamx`. `notify` pops a Termux notification. `unlink` forgets the phone. Phone needs Termux with sshd. No cloud involved.

## lamx-backup / lamx-wipe / recovery-key.sh

`lamx-backup /mnt/backup` snapshots root read-only and streams it GPG-encrypted to the target. `lamx-wipe /dev/disk` destroys data after typed ERASE. `recovery-key.sh` prints LUKS slots and TPM status for paper backup.

## lamx-xtreme — max limits mode

`sudo lamx-xtreme on` pins performance governor and energy preference, pauses thermald, maxes Nvidia if present, drops caches. Refuses on battery unless `--force`. `off` restores balanced profile. `status` shows state.

## lamx-glassy / lamx-setup / lamx-help

`lamx-glassy on` enables full SwayFX blur after extras install. `lamx-setup` reruns the first-boot wizard. `lamx-help` prints the condensed version of this page on device. First graphical login greets once with live protection state.

## kzc-digest — morning summary

Runs daily at 8 through a user timer: suspects, quarantines, decisions, top scorers. Run `kzc-digest` by hand anytime.

## VMs

`quickemu --vm name.conf --display spice` for instant ISO tests. `virt-manager` full GUI with UEFI and TPM passthrough, user already in libvirt and kvm groups. Both arrive with the installer extras step, rerun online if skipped.

## lamx-eye — privacy indicators

Mic, camera, and casting state from the PipeWire graph plus device handles, debounced. Plain output, `--watch` live view, `--json` for the Waybar pill that turns red while in use.

## lamx-idle — sip mode

`on` drops to powersave everything, still wallpaper, dimmed screen, services alive. `off` restores. `auto on` arms AC unplug and replug switching.

## lamx-adblock — resolver blocking

`on` pulls blocklists into hosts with weekly refresh. `off` restores. `update` refreshes. `allow` carves one domain back until next update.

## lamx-wallpaper — live engine

`auto`, `day`, or `night` plays mpvpaper video loops from Pictures with swww still fallback. `lamx-wallpaper-fetch day|night <url>` downloads open-licensed loops via yt-dlp.
