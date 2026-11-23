#!/usr/bin/env bash
# Run once on the sender Pi, from the repo root:  bash deploy/setup.sh
set -euo pipefail
cd "$(dirname "$0")/.."
REPO="$(pwd)"
echo "== Repo: $REPO"

echo "== Checking required files"
fail=0
need() { [ -e "$1" ] || { echo "MISSING: $1"; fail=1; }; }
need app.py
need model/__init__.py
need model/keypoint_classifier/keypoint_classifier.py
need model/keypoint_classifier/keypoint_classifier.onnx
need model/keypoint_classifier/keypoint_classifier_label.csv
need utils/utils.py
grep -q "stream_url" app.py                       || { echo "app.py is STALE: no stream_url"; fail=1; }
grep -q "HAND_SIGN_CONFIDENCE_THRESHOLD" app.py   || { echo "app.py is STALE: no confidence threshold"; fail=1; }
grep -q "headless" app.py                         || { echo "app.py is STALE: no --headless"; fail=1; }
grep -q "confidences" model/keypoint_classifier/keypoint_classifier.py || { echo "keypoint_classifier.py is STALE"; fail=1; }
[ "$fail" = 0 ] || { echo "Fix the above, then re-run."; exit 1; }

echo "== System packages"
sudo apt-get update
sudo apt-get install -y python3-venv ffmpeg tcpdump libgl1 libglib2.0-0 || true

echo "== Python venv (.venv)"
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install onnxruntime opencv-python-headless numpy
.venv/bin/python -c "import onnxruntime, cv2, numpy; print('imports OK', cv2.__version__, onnxruntime.__version__)"

echo "== Multicast-friendly sysctl"
echo 'net.core.rmem_max=26214400' | sudo tee /etc/sysctl.d/99-vidwall.conf >/dev/null
sudo sysctl --system >/dev/null

echo "== Done. Next: bash deploy/verify.sh"
