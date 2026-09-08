#!/usr/bin/env bash
set -euo pipefail
# codespace-vm - boot the lamX ISO in QEMU with browser display via noVNC
# runs in GitHub Codespaces (no KVM there, uses emulation, be patient).
# the ISO is NEVER downloaded, pass its path explicitly.
# usage: ./scripts/codespace-vm.sh /path/to/lamX.iso | stop | status
# then: forward port 6080 in the Codespaces Ports tab and open it in a browser.
VM_DIR="$HOME/.lamx-vm"
PID_QEMU="$VM_DIR/qemu.pid"
PID_WS="$VM_DIR/websockify.pid"
LOG="$VM_DIR/serial.log"
QEMU_LOG="$VM_DIR/qemu.log"
CMDLOG="$VM_DIR/cmdline.log"

case "${1:-}" in
  stop)
    kill "$(cat "$PID_QEMU" 2>/dev/null)" 2>/dev/null || true
    kill "$(cat "$PID_WS" 2>/dev/null)" 2>/dev/null || true
    rm -f "$PID_QEMU" "$PID_WS"
    echo stopped ;;
  status)
    if pgrep -f "qemu-system-x86_64.*lamX" >/dev/null; then echo "vm: running"; else echo "vm: stopped"; fi
    if pgrep -f "websockify.*6080" >/dev/null; then echo "novnc: running"; else echo "novnc: stopped"; fi
    [ -f "$CMDLOG" ] && { echo "--- last qemu cmdline ---"; cat "$CMDLOG"; } ;;
  "")
    echo "usage: $0 /path/to/lamX.iso | stop | status"; exit 1 ;;
  *)
    ISO="$1"
    [ -f "$ISO" ] || { echo "not found: $ISO"; exit 1; }
    ISO="$(realpath "$ISO")"
    MAGIC=$(dd if="$ISO" bs=1 skip=32769 count=5 2>/dev/null)
    [ "$MAGIC" = "CD001" ] || { echo "not an ISO image: $ISO"; exit 1; }
    command -v qemu-system-x86_64 >/dev/null || { sudo apt-get update -qq; sudo apt-get install -y -qq qemu-system-x86 novnc websockify; }
    command -v websockify >/dev/null || sudo apt-get install -y -qq novnc websockify
    mkdir -p "$VM_DIR"
    "$0" stop >/dev/null 2>&1 || true
    echo "booting $ISO (emulated, first boot takes minutes)"
    # shellcheck disable=SC2086
    qemu-system-x86_64 -accel tcg,thread=multi -m 3072 -smp 2 \
      -drive "file=$ISO,media=cdrom,readonly=on" -boot order=d -vga virtio \
      -display none -vnc :0 -serial "file:$LOG" >"$QEMU_LOG" 2>&1 &
    echo $! > "$PID_QEMU"
    echo "qemu-system-x86_64 -cdrom $ISO -boot order=d" > "$CMDLOG"
    websockify --web=/usr/share/novnc/ 6080 localhost:5900 >/dev/null 2>&1 &
    echo $! > "$PID_WS"
    sleep 8
    if kill -0 "$(cat "$PID_QEMU")" 2>/dev/null && (ss -ltn 2>/dev/null | grep -q 6080 || netstat -ltn 2>/dev/null | grep -q 6080); then
      echo "vm up, vnc on 6080. forward port 6080 in Ports tab, open it, press Connect"
    else
      echo "STARTUP-FAILED, qemu log:"; tail -n 15 "$QEMU_LOG"
      exit 1
    fi
    echo "serial log: $LOG" ;;
esac
