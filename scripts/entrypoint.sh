#!/usr/bin/env bash

set -euo pipefail

DISPLAY_NUM="${DISPLAY_NUM:-:1}"
VNC_PORT="${VNC_PORT:-5901}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
GEOMETRY="${GEOMETRY:-1920x1080x24}"
VNC_PASSWORD="${VNC_PASSWORD:-}"

/opt/scripts/install_robocode.sh

Xvfb "${DISPLAY_NUM}" -screen 0 "${GEOMETRY}" &
XVFB_PID=$!

export DISPLAY="${DISPLAY_NUM}"

fluxbox >/tmp/fluxbox.log 2>&1 &
FLUXBOX_PID=$!

if [[ -n "${VNC_PASSWORD}" ]]; then
  mkdir -p /root/.vnc
  x11vnc -storepasswd "${VNC_PASSWORD}" /root/.vnc/passwd
  x11vnc -display "${DISPLAY}" -rfbport "${VNC_PORT}" -forever -shared -rfbauth /root/.vnc/passwd >/tmp/x11vnc.log 2>&1 &
else
  x11vnc -display "${DISPLAY}" -rfbport "${VNC_PORT}" -forever -shared -nopw >/tmp/x11vnc.log 2>&1 &
fi
X11VNC_PID=$!

/usr/share/novnc/utils/novnc_proxy --vnc "127.0.0.1:${VNC_PORT}" --listen "${NOVNC_PORT}" >/tmp/novnc.log 2>&1 &
NOVNC_PID=$!

echo "Starting Robocode..."
/opt/robocode/robocode.sh >/tmp/robocode.log 2>&1 &
ROBOCODE_PID=$!

cleanup() {
  kill "${ROBOCODE_PID}" "${NOVNC_PID}" "${X11VNC_PID}" "${FLUXBOX_PID}" "${XVFB_PID}" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

wait "${ROBOCODE_PID}"
