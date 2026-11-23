#!/usr/bin/env bash
# Diagnostics. Run with sender.sh already running (or the service).
cd "$(dirname "$0")/.."
echo "== Services";  systemctl is-active vidwall-sender gesture 2>&1 | paste - -
echo "== Multicast route / interface"; ip route get 239.0.1.23
echo "== Packets on multicast group (5s)"
sudo timeout 5 tcpdump -ni any -c 5 udp and dst host 239.0.1.23 2>&1 | tail -6
echo "== Packets on loopback 1235 (5s)"
sudo timeout 5 tcpdump -ni lo -c 5 udp port 1235 2>&1 | tail -6
echo "== Can OpenCV decode the loopback stream?"
.venv/bin/python - <<'PY'
import cv2, time
cap = cv2.VideoCapture("udp://127.0.0.1:1235?overrun_nonfatal=1&fifo_size=5000000", cv2.CAP_FFMPEG)
t=time.time(); n=0
while time.time()-t<5:
    ok,f=cap.read()
    if ok: n+=1; shape=f.shape
print("frames in 5s:", n, "shape:", shape if n else None)
PY
echo "== Recent snapshots"; ls -lt snapshots 2>/dev/null | head -5
echo "== CPU/temp"; vcgencmd measure_temp; vcgencmd get_throttled; uptime
