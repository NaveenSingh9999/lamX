#!/usr/bin/env python3
"""Drive the VM over QMP: wait for login, sign in as root, start SDDM,
capture frames along the way. PPM frames become PNGs via stdlib."""
import json
import os
import socket
import struct
import subprocess
import time
import zlib

QMP = "qmp.sock"
OUT = "frames"
os.makedirs(OUT, exist_ok=True)

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


def wait_serial(text, timeout):
    end = time.time() + timeout
    while time.time() < end:
        try:
            with open("serial.log", errors="replace") as f:
                if text in f.read():
                    return True
        except OSError:
            pass
        time.sleep(5)
    return False


def sendkey(s, keys, hold=0.4):
    downs = [{"type": "qcode", "data": [k]} for k in keys]
    cmd(s, {"execute": "send-key", "arguments": {"keys": downs, "hold-time": int(hold * 1000)}})
    time.sleep(hold + 0.3)


def typeline(s, line):
    for ch in line:
        sendkey(s, [QCODE.get(ch, "spc")], 0.15)


def shot(s, name):
    cmd(s, {"execute": "screendump", "arguments": {"filename": f"/tmp/{name}.ppm"}})
    subprocess.run(["cp", f"/tmp/{name}.ppm", f"{OUT}/{name}.ppm"], check=False)
    time.sleep(2)


def ppm_to_png(src, dst):
    with open(src, "rb") as f:
        magic = f.readline()
        assert magic.strip() == b"P6"
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


s = qmp()
print("qmp up, waiting for boot menu", flush=True)
time.sleep(45)
shot(s, "01-syslinux")
print("waiting for login prompt", flush=True)
if not wait_serial("archlinux login:", 420):
    shot(s, "02-stuck")
    raise SystemExit("no login prompt")
shot(s, "02-console-login")
print("signing in as root", flush=True)
typeline(s, "root")
sendkey(s, ["ret"])
time.sleep(3)
sendkey(s, ["ret"])
time.sleep(3)
print("starting sddm", flush=True)
typeline(s, "systemctl start sddm")
sendkey(s, ["ret"])
for i in range(6):
    time.sleep(20)
    shot(s, f"03-sddm-{i}")
print("done", flush=True)
for f in sorted(os.listdir(OUT)):
    if f.endswith(".ppm"):
        ppm_to_png(os.path.join(OUT, f), os.path.join(OUT, f[:-4] + ".png"))
        os.remove(os.path.join(OUT, f))
