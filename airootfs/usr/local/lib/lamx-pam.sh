#!/usr/bin/env bash
# shared PAM wiring - backups first, passwords keep working without keys
pam-wire() {
  local f="$1"
  [ -f "$f" ] || return 0
  grep -q pam-u2f "$f" && return 0
  cp "$f" "$f.lamx-bak"
  { echo "auth sufficient pam_u2f.so authfile=/etc/pam-u2f/authfile cue no-user-touch openasuser";
    echo "auth [success=1 default=ignore] pam_oath.so usersfile=/etc/users.oath window=30 digits=6";
    cat "$f"; } > "$f.new" && mv "$f.new" "$f"
  echo "wired $f, backup at $f.lamx-bak"
}
