# Sessions: GUI, TUI, switching

## Login

Boot shows the Trueno lamX face, decrypts with PIN plus TPM, then SDDM astronaut with Jake: pick Caelestia shell or XFCE, authenticate with key touch or PIN plus Aegis code, Enter.

Other consoles: tty2–tty6 run plain getty logins, same passwordless PAM. SSH uses the same auth.

## Caelestia shell (default)

Quickshell desktop with dark scheme, bar, launcher, notifications, lock screen, control center. Media keys, brightness keys, and Mod+Return terminal work out of the box.

## XFCE desktop (second)

Classic panel workflow with mac-glass theming: dark theme, Pebble-Slate icons, IosevkaTerm terminal, rofi spotlight on Super+Space, music on Super+M. Power management and screensaver lock built in.

## Keys

| Keys | Action |
|---|---|
| Ctrl+Alt+T | terminal |
| Super+Space | spotlight search |
| Super+M | music |
| Alt+F2 | run command |
| Print | screenshot to clipboard |

Auto-lock on idle through the shell or screensaver, lid close locks.

## GUI to TUI and back

- GUI to console: Ctrl+Alt+F3 drops to tty3 getty. The graphical session keeps running on tty1.
- Back: Ctrl+Alt+F1 returns to SDDM, Ctrl+Alt+F2 usually holds the desktop session.
- Restart the desktop without rebooting: log out to SDDM and pick the other session.
- Reboot or poweroff from GUI: session menu, or `systemctl reboot` in terminal.
