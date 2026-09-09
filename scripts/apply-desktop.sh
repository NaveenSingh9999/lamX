#!/usr/bin/env bash
set -euo pipefail
# apply-desktop - lamX mac-glass xfce, rerunnable, needs a live session
# WhiteSur theme plus white mac cursors when present, Adwaita fallback.
# plank dock, transparent panel, video poster wallpaper, dark everything.
# usage: sudo ./scripts/apply-desktop.sh
[ "$EUID" -eq 0 ] || exec sudo "$0" "$@"
U="${SUDO_USER:-root}"
H=$(eval echo "~$U")
run_as() { sudo -u "$U" DISPLAY=:0 "$@"; }
THEME=Adwaita-dark
[ -d /usr/share/themes/WhiteSur-Dark ] && THEME=WhiteSur-Dark
CURSOR=Adwaita
[ -d /usr/share/icons/capitaine-cursors ] && CURSOR=capitaine-cursors
run_as xfconf-query -c xsettings -p /Net/ThemeName -s "$THEME" 2>/dev/null || true
run_as xfconf-query -c xsettings -p /Net/IconThemeName -s "Pebble-Slate" 2>/dev/null || true
run_as xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$CURSOR" 2>/dev/null || true
run_as xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s 24 2>/dev/null || true
run_as xfconf-query -c xfwm4 -p /general/theme -s "$THEME" 2>/dev/null || true
run_as xfconf-query -c xfwm4 -p /general/use_compositing -s true 2>/dev/null || true
run_as xfconf-query -c xfwm4 -p /general/frame_opacity -s 85 2>/dev/null || true
run_as xfconf-query -c xfwm4 -p /general/inactive_opacity -s 90 2>/dev/null || true
run_as xfconf-query -c xfwm4 -p /general/show_dock_shadow -s true 2>/dev/null || true
mkdir -p "$H/.icons/default"
printf '[Icon Theme]\nInherits=%s\n' "$CURSOR" > "$H/.icons/default/index.theme"
printf 'Xcursor.theme: %s\nXcursor.size: 24\n' "$CURSOR" >> "$H/.Xresources"
mkdir -p "$H/.config/gtk-3.0"
cat > "$H/.config/gtk-3.0/gtk.css" <<'EOF'
.xfce4-panel { background-color: rgba(10, 14, 26, 0.55); border-radius: 0 0 12px 12px; }
whiskermenu-button { background: transparent; }
wnck-pager:selected { background-color: rgba(59, 130, 246, 0.75); border-radius: 6px; }
EOF
STILL="$H/Pictures/wallpaper-still.png"
if [ ! -f "$STILL" ]; then
  VID="$H/Pictures/Wallpapers/live/wallpaper.mp4"
  [ -f "$VID" ] && ffmpeg -y -v error -i "$VID" -vframes 1 "$STILL" 2>/dev/null || \
    cp /usr/share/backgrounds/forest-day.png "$STILL" 2>/dev/null || true
fi
run_as xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$STILL" 2>/dev/null || true
if command -v xwinwrap >/dev/null && [ -f "$H/Pictures/Wallpapers/live/wallpaper.mp4" ]; then
  mkdir -p "$H/.config/autostart"
  cat > "$H/.config/autostart/lamx-livewall.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=lamX live wallpaper
Exec=sh -c 'xwinwrap -g 1920x1080 -ov -- mpv -wid WID --loop --no-audio --hwdec=auto $H/Pictures/Wallpapers/live/wallpaper.mp4'
EOF
fi
mkdir -p "$H/.config/autostart"
cat > "$H/.config/autostart/lamx-wallpaper.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=lamX wallpaper
Exec=lamx-wallpaper
EOF
cat > "$H/.config/autostart/plank.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Plank dock
Exec=plank
EOF
cat > "$H/.config/autostart/kzc-greet.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=lamX greet
Exec=kzc-greet
EOF
chown -R "$U:$U" "$H/.config/autostart" "$H/.icons" "$H/.Xresources" 2>/dev/null || true
[ -f "$STILL" ] && chown "$U:$U" "$STILL" 2>/dev/null || true
run_as xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>space" -s "lamx-spotlight" 2>/dev/null || true
run_as xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>m" -s "xfce4-terminal -e lamx-music" 2>/dev/null || true
run_as xfconf-query -c xfce4-screensaver -p /lock/enabled -s true 2>/dev/null || true
run_as xfconf-query -c xfce4-screensaver -p /lock/idle-delay -s 5 2>/dev/null || true
run_as xfconf-query -c xfce4-session -p /general/AutoSave -s false 2>/dev/null || true
echo "desktop applied ($THEME plus $CURSOR), relog to see everything"
rm -f "$H/.config/autostart/lamx-firstsetup.desktop"
