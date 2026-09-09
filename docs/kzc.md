# KZC architecture

On-device security with no network, no LLM, no API. Four layers, all open source.

## 1. Sensors

- **auditd** with `etc/audit/rules.d/kzc.rules`: identity files, sudo and polkit, module syscalls, mounts, persist paths, boot, plus KZC's own files. Immutable rules (`-e 2`).
- **eBPF** via bpftrace: `etc/kzc/execsnoop.bt` traces every exec with parent chain for on-demand forensics through `lamx-kzc trace`.
- **AppArmor** enforce system-wide plus a complain-mode browser profile whose denials feed detection signals without breaking anything.
- **AIDE** integrity base over bin, sbin, lib, etc, boot. Initialized at install, checked weekly by `kzc-aide.timer`, report in `/var/log/kzc`.
- **fwupd** refresh timer keeps device firmware patched.
- Daemon polling covers proc tree, module set, persist hashes, USB block devices, and established network remotes.

## 2. Brain

- **Multi-window EWMA** baselines at 1 minute, 5 minutes, 1 hour per exec pair. Three time scales catch bursts and slow drifts that single averages miss.
- **Rarity store** remembers first-seen exec pairs and network remotes forever. Novelty scores high on its own.
- **Privilege chains** fire regardless of frequency: GUI app spawning shells, shells reaching sudo, privileged tools loading modules. Shell escapes are killed on sight.
- **Quorum** weights every signal. Single blips log quietly. Corroborated signals notify, quarantine, and lock the session on critical chains.
- **Pacman suppression** pauses exec alerting during system updates so upgrades never spam, while persist and module watches stay armed.
- **Decay and trust**: scores fade on clean windows, day-old zeros drop off, allowlist entries skip detection in under 10 seconds.

## 3. Hands

Kill escapes, quarantine persist droppers with a restore manifest, lock sessions on critical chains, one rate-limited notification per signal, everything logged. `lamx-kzc restore` reverses mistakes.

## 4. Head

`kzc-head` daemon is the decision head. Critical scores act at once plus notify. Medium scores pop a rofi question with Quarantine, Allow always, Allow once, Watch, defaulting safe on timeout. TTY sessions get a wall broadcast instead. Every decision lands in `decisions.log` plus a review queue.

`opencode-kzc` serves the kzc-head agent as auditor over every decision. Live consult flips on with `KZC_CONSULT=1`, but opencode needs a model backend to think, so the rule head stays in charge for millisecond offline guarantees. The dashboard shows status, ranked suspects, quarantine with one-click restore, alerts, and config.

## No-disable design

Services use `RefuseManualStop` plus always-restart. Config and binaries sit under audit watch, the daemon checks its own hash. Only the device owner with the recovery story can stand it down.
