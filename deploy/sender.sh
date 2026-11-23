#!/usr/bin/env bash
# Camera -> multicast (video wall) AND -> localhost (gesture app).
# MCAST_IF: optional, interface IP to send multicast out of (e.g. 192.168.1.10)
MCAST="${MCAST:-239.0.1.23:1234}"
LOCAL="${LOCAL:-127.0.0.1:1235}"
IFACE_OPT=""
[ -n "${MCAST_IF:-}" ] && IFACE_OPT="&localaddr=${MCAST_IF}"

exec rpicam-vid -t 0 -n --width 1280 --height 720 --framerate 25 --intra 15 -o - \
 | ffmpeg -loglevel warning -nostats -i - -map 0:v -c:v copy -f tee \
   "[f=mpegts:onfail=ignore]udp://${MCAST}?pkt_size=1316&ttl=1${IFACE_OPT}|[f=mpegts:onfail=ignore]udp://${LOCAL}?pkt_size=1316"
