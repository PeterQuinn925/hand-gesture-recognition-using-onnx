#!/usr/bin/env bash
# Edit the paths/User in the .service files first if your repo isn't in /home/pi/hand-gesture-recognition-using-onnx
set -e
cd "$(dirname "$0")"
sudo cp vidwall-sender.service gesture.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now vidwall-sender gesture
systemctl status vidwall-sender gesture --no-pager
echo "Logs: journalctl -u gesture -f"
