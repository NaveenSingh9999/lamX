# Sessions: GUI, TUI, switching

## Login

Boot decrypts with PIN plus TPM, then greetd shows **tuigreet**: time, username field, session picker. Arrow keys choose **Sway** (default, battery) or **Hyprland** (animations), authenticate with key touch or PIN plus code, Enter. No graphical login manager by design — lighter and fewer moving parts.

Other consoles: tty2–tty6 run plain getty logins, same passwordless PAM. SSH uses the same auth.

## Sway (default)

CLI-first tiling, glassy transparent apps, auto Waybar, idle lock at 60 seconds, screen off at 5 minutes, welcome hint once.

## Hyprland (animations)

Same keybinds, same apps, plus bezier window motion, workspace slide, blur, gradient borders. Costs battery — pick per login depending on the day.

## Shared keys

| Keys | Action |
|---|---|
| Mod+Enter | terminal |
| Mod+D | app launcher |
| Mod+Space | spotlight search |
| Mod+M | music |
| Mod+Shift+E | exit session |
| Media keys | play, next, prev, mute, volume |
| Mod+1..4 | workspaces |

## Lock screen

swaylock takes the screen on idle, lid close, and sleep. Clock plus ring, blur variant after extras install. Same key auth to unlock. TTYs lock independently.

## GUI to TUI and back

- GUI to console: Ctrl+Alt+F3 drops to tty3 getty. Your graphical session keeps running on tty1.
- Back: Ctrl+Alt+F1 returns to greetd session.
- Kill a hung session: switch TTY, `loginctl terminate-session` or `swaymsg exit` / `hyprctl dispatch exit` from SSH.
- Reboot or poweroff from GUI: Mod+Shift+E exits, then `systemctl reboot` in console, or bind your own key.
