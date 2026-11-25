#!/usr/bin/env bash

set -euo pipefail

DISPLAY_NUM="${DISPLAY_NUM:-:1}"
GEOMETRY="${GEOMETRY:-1920x1080x24}"
VNC_PASSWORD="${VNC_PASSWORD:-}"

mkdir -p /opt/robocode/{battles,config,robots,roborumble}

pids=()
cleanup() {
  if (( ${#pids[@]} )); then
    kill "${pids[@]}" 2>/dev/null || true
  fi
}
trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

export DISPLAY="${DISPLAY_NUM}"
Xvfb "${DISPLAY}" -screen 0 "${GEOMETRY}" -nolisten tcp &
pids+=("$!")

for ((attempt = 0; attempt < 50; attempt++)); do
  if xdpyinfo >/dev/null 2>&1; then
    break
  fi
  sleep 0.2
done
if ! xdpyinfo >/dev/null 2>&1; then
  echo "Xvfb did not start on ${DISPLAY}." >&2
  exit 1
fi

fluxbox &
pids+=("$!")

vnc_auth=(-nopw)
if [[ -n "${VNC_PASSWORD}" ]]; then
  (umask 077; mkdir -p /root/.vnc; x11vnc -storepasswd "${VNC_PASSWORD}" /root/.vnc/passwd)
  vnc_auth=(-rfbauth /root/.vnc/passwd)
fi
x11vnc -display "${DISPLAY}" -localhost -rfbport 5901 -forever -shared "${vnc_auth[@]}" &
pids+=("$!")

/usr/share/novnc/utils/novnc_proxy --vnc 127.0.0.1:5901 --listen 6080 &
pids+=("$!")

echo "Starting Robocode..."
./robocode.sh &
pids+=("$!")

wait -n "${pids[@]}"
