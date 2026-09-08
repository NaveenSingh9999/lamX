#!/usr/bin/env bash
# welcome once on first Sway login, neutral
FLAG="$HOME/.config/.welcome-done"
[ -f "$FLAG" ] && exit 0
swaynag -t warning -m 'Welcome. Run lamx-help in terminal for commands.' -b 'Open terminal' 'exec foot' -b 'Dismiss' 'dismiss' &
mkdir -p "$HOME/.config"
touch "$FLAG"
