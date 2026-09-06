#!/usr/bin/env bash
set -euo pipefail
# lamX passwordless enroll - interim software version, FIDO later
# 1) TPM2+PIN for LUKS  2) phone TOTP for sudo/lock
# usage: sudo ./scripts/enroll-fido.sh /dev/disk/by-... <username>

DISK="${1:-}"
USERN="${2:-lamx}"
if [ -z "$DISK" ]; then
  echo "usage: sudo ./scripts/enroll-fido.sh /dev/nvme0n1p2 lamx"
  exit 1
fi

echo "[1/3] Enroll TPM2+PIN for $DISK"
systemd-cryptenroll --tpm2-device=auto --tpm2-with-pin=yes --tpm2-pcrs=0+7 "$DISK"

echo "[2/3] Prepare pam_u2f for phone + future hardware key"
mkdir -p /etc/pam-u2f
authfile="/etc/pam-u2f/authfile"
touch "$authfile"
chmod 600 "$authfile"
echo "Run on each device to enroll:"
echo "  pamu2fcfg -u $USERN >> $authfile   # phone via USB, then hardware key later"

echo "[3/3] Prepare TOTP backup with Aegis"
echo "Run: oathtool --base32 --totp \$(head -c 20 /dev/urandom | base32) and scan in Aegis"
echo "Add to /etc/pam.d/sudo and swaylock:"
echo "  auth sufficient pam_u2f.so authfile=$authfile cue no-user-touch"
echo "  auth required pam_oath.so usersfile=/etc/users.oath window=30"
echo "Done. No long passwords stored."
