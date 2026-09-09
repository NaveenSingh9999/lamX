#!/usr/bin/env bash
set -euo pipefail
# codespace-vm - boot the lamX ISO in QEMU with browser display via noVNC
# runs in GitHub Codespaces (no KVM there, uses emulation, be patient).
# the ISO is NEVER downloaded, pass its path explicitly.
# usage: ./scripts/codespace-vm.sh /path/to/lamX.iso [vnc|term] | stop | status
# vnc mode serves display on port 6080 for the browser, term mode attaches
# the serial console to this terminal instead. kvm plus host cpu when present.
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
    MODE="${2:-vnc}"
    [ -f "$ISO" ] || { echo "not found: $ISO"; exit 1; }
    ISO="$(realpath "$ISO")"
    MAGIC=$(dd if="$ISO" bs=1 skip=32769 count=5 2>/dev/null)
    [ "$MAGIC" = "CD001" ] || { echo "not an ISO image: $ISO"; exit 1; }
    if [ ! -f "$VM_DIR/disk.img" ]; then
      echo "creating 10G disk at $VM_DIR/disk.img"
      qemu-img create -f qcow2 "$VM_DIR/disk.img" 10G
    fi
    command -v qemu-system-x86_64 >/dev/null || { sudo apt-get update -qq; sudo apt-get install -y -qq qemu-system-x86 qemu-utils novnc websockify; }
    command -v websockify >/dev/null || sudo apt-get install -y -qq novnc websockify
    mkdir -p "$VM_DIR"
    "$0" stop >/dev/null 2>&1 || true
    echo "booting $ISO ($MODE mode, kvm if present, else emulated)"
    if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
      ACCEL="-machine accel=kvm -cpu host"
    else
      ACCEL="-accel tcg,thread=multi"
    fi
    # shellcheck disable=SC2086
    if [ "$MODE" = "term" ]; then
      exec qemu-system-x86_64 $ACCEL -m 6144 -smp 4 \
        -drive "file=$ISO,media=cdrom,readonly=on" -drive "file=$VM_DIR/disk.img,format=qcow2,if=virtio" \
        -boot order=d -vga virtio \
        -display none -serial mon:stdio -monitor "unix:$VM_DIR/mon.sock,server=on,wait=off"
    fi
    qemu-system-x86_64 $ACCEL -m 6144 -smp 4 \
      -drive "file=$ISO,media=cdrom,readonly=on" -drive "file=$VM_DIR/disk.img,format=qcow2,if=virtio" \
      -boot order=d -vga virtio \
      -display none -vnc :0 -serial "file:$LOG" -monitor "unix:$VM_DIR/mon.sock,server=on,wait=off" >"$QEMU_LOG" 2>&1 &
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
