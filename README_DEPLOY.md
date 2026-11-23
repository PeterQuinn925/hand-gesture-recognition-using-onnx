# Gesture snapshot – deployment bundle

Copy these over your repo (`hand-gesture-recognition-using-onnx/`), keeping paths:
- `app.py` -> repo root (replaces old; adds --headless, reconnect, absolute snapshot dir, no output.mp4)
- `model/keypoint_classifier/keypoint_classifier.py` -> same path
- `deploy/` -> repo root (scripts + systemd units)
- `tools/` -> optional (HaGRID extraction / OK data check; move to repo root to run)
NOT included (you already have them): `model/*.onnx`, `model/__init__.py`, `utils/`. setup.sh refuses to continue if any are missing.

**Best: one `git init` on the laptop, push to GitHub, `git clone` on every Pi. No more stale copies.**

## Today: test on the spare Pi 4
1. `bash deploy/setup.sh`  (checks files aren't stale, builds `.venv`)
2. Terminal A: `bash deploy/sender.sh`   (camera -> multicast + localhost)
3. Terminal B: `.venv/bin/python app.py --headless --stream_url "udp://127.0.0.1:1235?overrun_nonfatal=1&fifo_size=5000000"`
   (no monitor? add nothing; with monitor and desktop, drop `--headless` to see the overlay)
4. Make a fist / OK at the camera -> `snapshots/snapshot_close_*.png` / `snapshot_ok_*.png`
5. `htop` during the run. App at ~100% of one core is fine. If sender stutters, tell me and I'll add frame-skipping (process every Nth frame).
6. `bash deploy/verify.sh` for diagnostics.
7. Service test: `bash deploy/install_services.sh`, reboot, confirm snapshots still work with nobody logged in. Logs: `journalctl -u gesture -f`.
   (Stop the manual terminals first - the camera can only be opened once.)

Without a tile Pi nearby, check multicast leaves the Pi: `sudo tcpdump -ni eth0 dst host 239.0.1.23`.
Note: the Pi must have a default route/link up for multicast; if sending fails with "Network unreachable", set `MCAST_IF=<pi ip>` or `sudo ip route add 239.0.0.0/8 dev eth0`.

## Museum checklist (next week)
- New switch: must support **IGMP snooping + a querier** (or be unmanaged and dumb - then multicast floods like broadcast, fine for a small wall but slow with many devices). Unmanaged multicast-flooding switches are OK; the "very slow" issue was broadcast over the old switch.
- Tile Pis: unchanged command (`-vf "crop=640:360:X:Y,format=rgb565le"`, `-buffer_size 8192000`, `sysctl net.core.rmem_max=26214400`).
- Tile Pis' receive URL stays `udp://239.0.1.23:1234`.
- Pull the repo, run `setup.sh`, `install_services.sh`, reboot, run `verify.sh`.
- Snapshots go to `<repo>/snapshots` - clear it periodically (disk). 
- Keep the Close trigger as the safe default; OK sign depends on your retrained model.
