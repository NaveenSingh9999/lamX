#!/usr/bin/env bash
set -euo pipefail
# recovery-key - show LUKS slots and TPM status for offline paper backup
# usage: sudo ./scripts/recovery-key.sh /dev/nvme0n1p2
DISK="${1:-}"
[ -n "$DISK" ] || { echo "usage: sudo ./scripts/recovery-key.sh /dev/nvme0n1p2"; exit 1; }
cryptsetup luksDump "$DISK" | grep -E "Slot|tpm|fido|pbkdf"
systemd-cryptenroll --tpm2-device=list || true
echo "Write down one recovery passphrase and store offline. Never store in repo."
