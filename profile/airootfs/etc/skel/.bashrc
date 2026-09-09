# shell defaults - neutral
alias ll='ls -lah'
alias lamx-help='lamx-help'
export EDITOR=nvim
export TERMINAL=xfce4-terminal
# show help once per shell until setup done
if [ ! -f "$HOME/.config/.setup-done" ]; then
  echo "Run 'sudo lamx-setup' for first-time setup. 'lamx-help' for commands."
fi
