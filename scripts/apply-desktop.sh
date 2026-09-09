#!/usr/bin/env bash
set -euo pipefail
# apply-desktop - lamX desktop from the best community work, installed not baked
# sway structure and keychord modes follow bibjaw99/workstation,
# hyprland motion follows nv8v/workstation, apps and colors stay lamX.
# safe to rerun. usage: sudo ./scripts/apply-desktop.sh
[ "$EUID" -eq 0 ] || exec sudo "$0" "$@"

# ---- helpers both sessions share ----
install -m755 /dev/stdin /usr/local/bin/lamx-powermenu <<'EOF'
#!/usr/bin/env bash
OPT=$(printf 'Lock\nLogout\nSuspend\nReboot\nPoweroff' | wofi --show dmenu -p ">" -i) || exit 0
case "$OPT" in
  Lock) swaylock -f -c 0a0e1a 2>/dev/null || loginctl lock-session ;;
  Logout) swaymsg exit 2>/dev/null || hyprctl dispatch exit 2>/dev/null || loginctl terminate-user "$USER" ;;
  Suspend) systemctl suspend ;;
  Reboot) systemctl reboot ;;
  Poweroff) systemctl poweroff ;;
esac
EOF
install -m755 /dev/stdin /usr/local/bin/lamx-shot <<'EOF'
#!/usr/bin/env bash
MODE="${1:-area}"
DIR="$HOME/Pictures/Shots"
mkdir -p "$DIR"
if [ "$MODE" = "full" ]; then
  F="$DIR/shot-$(date +%Y%m%d-%H%M%S).png"
  grim "$F" && echo "saved $F"
else
  grim -g "$(slurp)" - | wl-copy && notify-send "Shot" "area copied to clipboard" || true
fi
EOF

# ---- sway, bibjaw99 structure with lamX apps ----
cat > /etc/sway/config.d/lamx <<'EOF'
# lamX sway - keychord modes and workspace discipline from bibjaw99/workstation
set $mod Mod4
set $ws1 "1"; set $ws2 "2"; set $ws3 "3"; set $ws4 "4"
set $ws5 "5"; set $ws6 "6"; set $ws7 "7"; set $ws8 "8"
set $term foot
set $menu wofi --show drun -p ">"
set $bg #0a0e1a
set $fg #3b82f6
set $tx #e5e5e5
set $wr #ef4444

output * bg $bg solid_color
output * mode 1920x1080
exec waybar
exec mako
exec lamx-wallpaper
exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec ~/.config/sway-welcome.sh
exec kzc-greet
exec eww daemon --config /etc/xdg/eww 2>/dev/null; eww open clock --config /etc/xdg/eww 2>/dev/null || true
exec swayidle -w timeout 60 'swaylock -f -c 0a0e1a' timeout 300 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' before-sleep 'swaylock -f -c 0a0e1a'

title_align center
font pango:IosevkaTerm Nerd Font 10
titlebar_border_thickness 2
titlebar_padding 3
default_border pixel 2
for_window [app_id="^.*"] border pixel 2
gaps inner 8
gaps outer 6
smart_gaps on
workspace_layout default
mouse_warping none
seat * hide_cursor 5000
focus_follows_mouse no
client.focused $fg $fg #ffffff $fg $fg
client.unfocused #1e293b #1e293b #94a3b8 #1e293b #1e293b
client.focused_inactive #1e293b #1e293b $tx #1e293b #1e293b
client.urgent $wr $wr #ffffff $wr $wr
floating_modifier $mod

assign [app_id="(?i).*foot.*"] $ws1
assign [app_id="(?i).*librewolf.*"] $ws2
assign [app_id="(?i).*zen.*"] $ws2
assign [app_id="(?i).*mpv.*"] $ws4

bindsym button4 nop
bindsym button5 nop
bindgesture swipe:right focus next
bindgesture swipe:left focus prev
bindgesture swipe:up workspace prev
bindgesture swipe:down workspace next

bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4
bindsym $mod+5 workspace $ws5
bindsym $mod+6 workspace $ws6
bindsym $mod+7 workspace $ws7
bindsym $mod+8 workspace $ws8
bindsym $mod+Shift+1 move container to workspace $ws1
bindsym $mod+Shift+2 move container to workspace $ws2
bindsym $mod+Shift+3 move container to workspace $ws3
bindsym $mod+Shift+4 move container to workspace $ws4
bindsym $mod+Shift+5 move container to workspace $ws5
bindsym $mod+Shift+6 move container to workspace $ws6
bindsym $mod+Shift+7 move container to workspace $ws7
bindsym $mod+Shift+8 move container to workspace $ws8
bindsym $mod+Tab workspace next_on_output
bindsym Mod1+Tab workspace prev_on_output

bindsym $mod+Shift+q kill
bindsym $mod+Shift+r reload
bindsym $mod+m fullscreen toggle
bindsym $mod+Shift+o layout toggle tabbed splitv splith
bindsym $mod+a splitv
bindsym $mod+Shift+a splith
bindsym $mod+space floating toggle; [floating con_id="__focused__"] move position center; [floating con_id="__focused__"] resize set 70ppt 75ppt
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right
bindsym $mod+u focus parent
bindsym $mod+i focus child
bindsym $mod+n focus mode_toggle
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right
bindsym $mod+Ctrl+h resize grow width 20 px or 5 ppt
bindsym $mod+Ctrl+j resize shrink height 20 px or 5 ppt
bindsym $mod+Ctrl+k resize grow height 20 px or 5 ppt
bindsym $mod+Ctrl+l resize shrink width 20 px or 5 ppt
mode "swap" {
  bindsym $mod+Shift+h mark --add "_swap", focus left, swap container with mark "_swap", focus left, unmark "_swap"; mode default
  bindsym $mod+Shift+j mark --add "_swap", focus down, swap container with mark "_swap", focus down, unmark "_swap"; mode default
  bindsym $mod+Shift+k mark --add "_swap", focus up, swap container with mark "_swap", focus up, unmark "_swap"; mode default
  bindsym $mod+Shift+l mark --add "_swap", focus right, swap container with mark "_swap", focus right, unmark "_swap"; mode default
  bindsym Escape mode "default"
  bindsym Return mode "default"
}
mode "launch" {
  bindsym $mod+Return exec $term; mode "default"
  bindsym $mod+d exec $menu; mode "default"
  bindsym $mod+m exec foot lamx-music; mode "default"
  bindsym Escape mode "default"
  bindsym Return mode "default"
}
bindsym $mod+Return mode "launch"
bindsym $mod+d exec $menu
bindsym $mod+space exec lamx-spotlight
bindsym $mod+Shift+u mode "swap"
bindsym $mod+Shift+x exec swaylock -f -c 0a0e1a
bindsym $mod+Shift+e exec lamx-powermenu
bindsym Print exec lamx-shot
bindsym $mod+Print exec lamx-shot full
bindsym XF86MonBrightnessUp exec brightnessctl set +5%
bindsym XF86MonBrightnessDown exec brightnessctl --min-value=1 set 5%-
bindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindsym XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous
bindsym $mod+m exec foot lamx-music
EOF

# ---- waybar, full productive set ----
cat > /etc/xdg/waybar/config <<'EOF'
{
  "layer": "top",
  "position": "top",
  "height": 34,
  "spacing": 6,
  "margin-top": 8,
  "margin-left": 10,
  "margin-right": 10,
  "modules-left": ["wlr/workspaces", "sway/mode", "sway/window"],
  "modules-center": ["clock"],
  "modules-right": ["custom/privacy", "cpu", "memory", "pulseaudio", "network", "backlight", "battery", "tray", "custom/power"],
  "wlr/workspaces": { "format": "{icon}", "format-icons": { "1": "1", "2": "2", "3": "3", "4": "4", "5": "5", "6": "6", "7": "7", "8": "8" } },
  "sway/window": { "format": "{}", "max-length": 40 },
  "clock": { "format": "{:%H:%M  %a %d-%m}", "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>" },
  "cpu": { "format": "{usage}% ", "interval": 3 },
  "memory": { "format": "{}% ", "interval": 5 },
  "battery": { "format": "{capacity}% {icon}", "format-icons": ["", "", "", "", ""] },
  "network": { "format-wifi": " {signalStrength}%", "format-ethernet": "", "format-disconnected": "", "tooltip-format": "{ifname} {ipaddr}" },
  "pulseaudio": { "format": "{volume}% ", "format-muted": "" },
  "backlight": { "format": "{percent}% " },
  "tray": { "spacing": 6 },
  "custom/privacy": { "exec": "lamx-eye --json", "interval": 2, "return-type": "json", "on-click": "foot lamx-eye" },
  "custom/power": { "format": "", "on-click": "lamx-powermenu" }
}
EOF

# ---- hyprland, nv8v motion plus bibjaw99 submaps, lamX apps ----
cat > /etc/xdg/hypr/hyprland.conf <<'EOF'
# lamX hyprland - motion from nv8v/workstation, keychords from bibjaw99/workstation
monitor = ,1920x1080@60,auto,1
$mainMod = SUPER
$terminal = foot
$browser = zen
$menu = wofi --show drun -p ">"
$lockscreen = swaylock -f -c 0a0e1a
$resetSubMap = hyprctl dispatch submap reset
$toggle_floating_window = hyprctl dispatch togglefloating; hyprctl dispatch centerwindow

exec-once = waybar
exec-once = mako
exec-once = lamx-wallpaper
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = kzc-greet
exec-once = sh -c 'eww daemon --config /etc/xdg/eww; eww open clock --config /etc/xdg/eww'
exec-once = swayidle -w timeout 60 'swaylock -f -c 0a0e1a' timeout 300 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -f -c 0a0e1a'

input {
  kb_layout = us
  follow_mouse = 1
  touchpad { natural_scroll = yes, disable_while_typing = true }
}
gesture = 3, up, dispatcher, workspace, e-1
gesture = 3, down, dispatcher, workspace, e+1
gesture = 3, left, dispatcher, layoutmsg, cycleprev
gesture = 3, right, dispatcher, layoutmsg, cyclenext

general {
  gaps_in = 8
  gaps_out = 6
  border_size = 2
  col.active_border = rgba(3b82f6ee) rgba(60a5faee) 45deg
  col.inactive_border = rgba(1e293bcc)
  layout = master
}
master {
  mfact = 0.5
  new_on_top = true
}
decoration {
  rounding = 12
  active_opacity = 1.0
  inactive_opacity = 0.97
  shadow { enabled = yes, range = 20, render_power = 3, color = rgba(00000099) }
  blur { enabled = yes, size = 6, passes = 2, brightness = 1.0, contrast = 1.0, vibrancy = 0.15 }
}
animations {
  enabled = yes
  bezier = fluent_decel, 0.1, 1, 0, 1
  bezier = md3_decel, 0.05, 0.7, 0.1, 1
  bezier = md3_accel, 0.3, 0, 0.8, 0.15
  bezier = elegant_bounce, 0.55, 1.07, 0.28, 1.12
  bezier = linear, 1, 1, 1, 1
  animation = windowsIn, 1, 5, elegant_bounce, slide down
  animation = windowsOut, 1, 4, md3_accel, slide up
  animation = windowsMove, 1, 5, fluent_decel, slide
  animation = border, 1, 3, md3_decel
  animation = borderangle, 1, 30, linear, loop
  animation = fade, 1, 3, md3_decel
  animation = workspaces, 1, 5, fluent_decel, slidevert
  animation = layersIn, 1, 4, fluent_decel, slide
  animation = layersOut, 1, 4, md3_accel, slide
}
misc {
  disable_hyprland_logo = true
  disable_splash_rendering = true
}
windowrulev2 = opacity 0.92 0.92, class:^(foot)$
windowrulev2 = workspace 2, class:^(librewolf)$|class:^(zen)$
layerrule = blur, waybar
layerrule = blur, notifications

bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod SHIFT, 1, movetoworkspacesilent, 1
bind = $mainMod SHIFT, 2, movetoworkspacesilent, 2
bind = $mainMod SHIFT, 3, movetoworkspacesilent, 3
bind = $mainMod SHIFT, 4, movetoworkspacesilent, 4
bind = $mainMod SHIFT, 5, movetoworkspacesilent, 5
bind = $mainMod SHIFT, 6, movetoworkspacesilent, 6
bind = $mainMod SHIFT, 7, movetoworkspacesilent, 7
bind = $mainMod SHIFT, 8, movetoworkspacesilent, 8
bind = $mainMod, Tab, workspace, e+1
bind = Mod1, Tab, workspace, e-1
bind = $mainMod SHIFT, X, exec, $lockscreen
bind = $mainMod SHIFT, Q, killactive,
bind = $mainMod, m, fullscreen, 1
bind = $mainMod, Space, exec, $toggle_floating_window
bind = $mainMod, h, movefocus, l
bind = $mainMod, j, movefocus, d
bind = $mainMod, k, movefocus, u
bind = $mainMod, l, movefocus, r
bind = $mainMod SHIFT, h, movewindow, l
bind = $mainMod SHIFT, j, movewindow, d
bind = $mainMod SHIFT, k, movewindow, u
bind = $mainMod SHIFT, l, movewindow, r
bind = $mainMod, M, exec, foot lamx-music
bind = $mainMod SHIFT, E, exec, lamx-powermenu
bind = , PRINT, exec, lamx-shot
bind = $mainMod, PRINT, exec, lamx-shot full
bindel = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
bindel = , XF86MonBrightnessDown, exec, brightnessctl --min-value=1 set 5%-
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
submap = launch
bind = $mainMod, Return, exec, $terminal & $resetSubMap
bind = $mainMod, d, exec, $menu & $resetSubMap
bind = $mainMod, w, exec, $browser & $resetSubMap
bind = , catchall, exec, $resetSubMap
submap = reset
submap = rofi
bind = $mainMod, Space, exec, lamx-spotlight & $resetSubMap
bind = , catchall, exec, $resetSubMap
submap = reset
bind = $mainMod, Return, submap, launch
bind = $mainMod, d, submap, rofi
EOF

# ---- waybar glass to match ----
cat > /etc/xdg/waybar/style.css <<'EOF'
* { font-family: "IosevkaTerm Nerd Font", monospace; font-size: 12px; border: none; }
window#waybar { background: rgba(10, 14, 26, 0.55); color: #e5e5e5; border-radius: 12px; border: 1px solid rgba(59, 130, 246, 0.25); }
#workspaces button { padding: 2px 8px; color: #94a3b8; background: transparent; border-radius: 8px; }
#workspaces button.focused { background: rgba(59, 130, 246, 0.75); color: #ffffff; }
#workspaces button:hover { background: rgba(59, 130, 246, 0.3); }
#clock, #battery, #network, #pulseaudio, #tray, #custom-privacy, #custom-power, #cpu, #memory, #backlight, #sway-mode { padding: 0 10px; margin: 4px 2px; background: rgba(255, 255, 255, 0.06); border-radius: 8px; }
#battery.critical { color: #ef4444; }
#custom-privacy.active { background: rgba(239, 68, 68, 0.35); border: 1px solid rgba(239, 68, 68, 0.6); }
tooltip { background: rgba(10, 14, 26, 0.9); border: 1px solid rgba(59, 130, 246, 0.3); border-radius: 8px; }
EOF

echo "desktop applied, restart the session"
