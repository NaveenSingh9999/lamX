#!/usr/bin/env python3
"""Drive the VM over QMP plus an interactive serial socket.
Sign in on serial, start SDDM, photograph every stage."""
import json
import os
import socket
import struct
import subprocess
import threading
import time
import zlib

QMP = "qmp.sock"
SER = "serial.sock"
OUT = "frames"
os.makedirs(OUT, exist_ok=True)
LOGF = open("serial.log", "wb", buffering=0)

QCODE = {c: c for c in "abcdefghijklmnopqrstuvwxyz0123456789"}
QCODE.update({" ": "spc", "-": "minus", "_": "minus", "/": "slash",
              ".": "dot", ":": "semicolon", "@": "semicolon"})


def qmp():
    for _ in range(60):
        try:
            s = socket.socket(socket.AF_UNIX)
            s.connect(QMP)
            s.settimeout(10)
            s.recv(65536)
            s.send(b'{"execute":"qmp_capabilities"}')
            s.recv(65536)
            return s
        except OSError:
            time.sleep(5)
    raise SystemExit("no qmp")


def cmd(s, obj):
    s.send((json.dumps(obj) + "\n").encode())
    data = b""
    while b'"return"' not in data and b'"error"' not in data:
        chunk = s.recv(65536)
        if not chunk:
            break
        data += chunk
    return data


def shot(s, name):
    cmd(s, {"execute": "screendump", "arguments": {"filename": f"/tmp/{name}.ppm"}})
    subprocess.run(["cp", f"/tmp/{name}.ppm", f"{OUT}/{name}.ppm"], check=False)
    time.sleep(2)


def ppm_to_png(src, dst):
    with open(src, "rb") as f:
        assert f.readline().strip() == b"P6"
        line = f.readline()
        while line.startswith(b"#"):
            line = f.readline()
        w, h = map(int, line.split())
        f.readline()
        px = f.read(w * h * 3)
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        raw += px[y * w * 3:(y + 1) * w * 3]

    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        return c + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    png = (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(bytes(raw), 6)) + chunk(b"IEND", b""))
    open(dst, "wb").write(png)


class Serial:
    def __init__(self):
        self.buf = bytearray()
        self.sock = None

    def connect(self):
        for _ in range(90):
            try:
                self.sock = socket.socket(socket.AF_UNIX)
                self.sock.connect(SER)
                self.sock.settimeout(5)
                threading.Thread(target=self._pump, daemon=True).start()
                return
            except OSError:
                time.sleep(5)
        raise SystemExit("no serial")

    def _pump(self):
        while True:
            try:
                d = self.sock.recv(65536)
                if not d:
                    return
                self.buf += d
                LOGF.write(d)
            except OSError:
                return

    def expect(self, text, timeout):
        end = time.time() + timeout
        while time.time() < end:
            if text.encode() in bytes(self.buf):
                return True
            time.sleep(5)
        return False

    def send(self, text):
        self.sock.send(text.encode())
        time.sleep(2)


s = qmp()
print("qmp up", flush=True)
time.sleep(40)
shot(s, "01-syslinux")
ser = Serial()
ser.connect()
print("serial up", flush=True)
if not ser.expect("archlinux login:", 420):
    shot(s, "02-stuck")
    raise SystemExit("no login prompt")
shot(s, "02-console-login")
print("signing in", flush=True)
ser.send("root\n")
ser.expect("Password:", 30)
ser.send("\n")
if not ser.expect("root@archlinux", 30):
    shot(s, "03-login-failed")
    raise SystemExit("signin failed")
print("starting sddm", flush=True)
ser.send("systemctl start sddm\n")
for i in range(6):
    time.sleep(20)
    shot(s, f"04-sddm-{i}")
print("journal check", flush=True)
ser.send("systemctl is-active sddm; loginctl --no-legend\n")
time.sleep(10)
shot(s, "05-final")
print("done", flush=True)
for f in sorted(os.listdir(OUT)):
    if f.endswith(".ppm"):
        ppm_to_png(os.path.join(OUT, f), os.path.join(OUT, f[:-4] + ".png"))
        os.remove(os.path.join(OUT, f))
