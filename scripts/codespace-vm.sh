#!/usr/bin/env bash
set -euo pipefail
# codespace-vm - boot the lamX ISO in QEMU with browser display via noVNC
# runs in GitHub Codespaces (no KVM there, uses emulation, be patient).
# the ISO is NOT downloaded, it must already exist (out/ or path argument).
# usage: ./scripts/codespace-vm.sh [path-to.iso] | stop | status
# then: forward port 6080 in the Codespaces Ports tab and open it in a browser.
VM_DIR="$HOME/.lamx-vm"
PID_QEMU="$VM_DIR/qemu.pid"
PID_WS="$VM_DIR/websockify.pid"
LOG="$VM_DIR/serial.log"

iso_path() {
  if [ -n "${1:-}" ]; then echo "$1"; return; fi
  ls -t out/*.iso "$HOME"/lamX-*.iso 2>/dev/null | head -n1
}

case "${1:-start}" in
  stop)
    kill "$(cat "$PID_QEMU" 2>/dev/null)" 2>/dev/null || true
    kill "$(cat "$PID_WS" 2>/dev/null)" 2>/dev/null || true
    rm -f "$PID_QEMU" "$PID_WS"
    echo stopped ;;
  status)
    pgrep -f "qemu-system-x86_64.*lamX" >/dev/null && echo "vm: running" || echo "vm: stopped"
    pgrep -f "websockify.*6080" >/dev/null && echo "novnc: running" || echo "novnc: stopped" ;;
  start|*)
    [ "${1:-start}" = "start" ] || ISO_ARG="$1"
    ISO=$(iso_path "${ISO_ARG:-}")
    [ -n "$ISO" ] && [ -f "$ISO" ] || { echo "no ISO found, pass a path"; exit 1; }
    sudo apt-get update -qq
    sudo apt-get install -y -qq qemu-system-x86 novnc websockify
    mkdir -p "$VM_DIR"
    "$0" stop >/dev/null 2>&1 || true
    echo "booting $ISO (emulated, first boot takes minutes)"
    qemu-system-x86_64 -accel tcg,thread=multi -m 3072 -smp 2 \
      -cdrom "$ISO" -boot order=d -vga virtio \
      -display none -vnc :0 -serial "file:$LOG" >/dev/null 2>&1 &
    echo $! > "$PID_QEMU"
    websockify --web=/usr/share/novnc/ 6080 localhost:5900 >/dev/null 2>&1 &
    echo $! > "$PID_WS"
    sleep 3
    echo "open the Ports tab, forward port 6080 as public, browse to it and press Connect"
    echo "serial log: $LOG" ;;
esac
