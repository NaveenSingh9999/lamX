# Sessions: GUI, TUI, switching

## Login

Boot decrypts with PIN plus TPM, then greetd shows **tuigreet**: time, username field, and session picker. Choose the XFCE session, authenticate with key touch or PIN plus Aegis code, Enter. No graphical login manager by design — lighter and fewer moving parts.

Other consoles: tty2–tty6 run plain getty logins, same passwordless PAM. SSH uses the same auth.

## XFCE desktop

Classic panel workflow with lamX theming: dark Adwaita, Pebble-Slate icons, IosevkaTerm everywhere, forest still wallpaper with the live loop one fetch away. Power management and screensaver lock built in.

## Keys

| Keys | Action |
|---|---|
| Ctrl+Alt+T | terminal |
| Super+Space | spotlight search |
| Super+M | music |
| Alt+F2 | run command |
| Print | screenshot to clipboard |

Auto-lock on idle through the screensaver, lid close locks.

## GUI to TUI and back

- GUI to console: Ctrl+Alt+F3 drops to tty3 getty. The graphical session keeps running on tty1.
- Back: Ctrl+Alt+F1 returns to the desktop.
- Restart the desktop without rebooting: log out from the panel menu, pick the session again at tuigreet.
- Reboot or poweroff from GUI: panel menu, or `systemctl reboot` in terminal.
