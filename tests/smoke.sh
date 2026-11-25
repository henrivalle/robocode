#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
export ROBOCODE_WEB_PORT=0 ROBOCODE_GEOMETRY=800x600x24 ROBOCODE_VNC_PASSWORD=
project="robocode-smoke-$$-${RANDOM}"

compose() {
  docker compose --env-file /dev/null --project-name "$project" "$@"
}

cleanup() {
  local status=$?
  if (( status != 0 )); then
    compose logs --tail 120 || true
  fi
  compose down --volumes --rmi local >&2 || true
}
trap cleanup EXIT

check_browser_endpoint() {
  local address
  address=$(compose port robocode-web 6080)
  curl -fsS "http://${address}/vnc.html" >/dev/null

  python3 - "${address##*:}" <<'PY'
import base64
import hashlib
import os
import socket
import sys

port = int(sys.argv[1])
key = base64.b64encode(os.urandom(16)).decode()
accept = base64.b64encode(hashlib.sha1((key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").encode()).digest())
with socket.create_connection(("127.0.0.1", port), timeout=5) as connection:
    connection.sendall((
        f"GET /websockify HTTP/1.1\r\nHost: 127.0.0.1:{port}\r\n"
        "Upgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\n"
        f"Sec-WebSocket-Key: {key}\r\nSec-WebSocket-Protocol: binary\r\n\r\n"
    ).encode())
    with connection.makefile("rb") as stream:
        assert stream.readline().split()[1] == b"101", "Missing WebSocket upgrade"
        headers = {}
        for line in iter(stream.readline, b"\r\n"):
            name, value = line.split(b":", 1)
            headers[name.lower()] = value.strip()
        assert headers[b"sec-websocket-accept"] == accept
        opcode, length = stream.read(2)
        assert opcode == 0x82 and length == 12, (opcode, length)
        assert stream.read(length).startswith(b"RFB "), "Missing VNC server banner"
PY
}

check_window() {
  for ((attempt = 0; attempt < 30; attempt++)); do
    if compose exec -T robocode-web xwininfo -display :1 -root -tree | grep '"Robocode' >/dev/null; then
      return
    fi
    sleep 1
  done
  echo 'Robocode GUI did not start.' >&2
  return 1
}

compose up --build --detach --wait --wait-timeout 120
check_window
check_browser_endpoint
compose exec -T robocode-web test -f /opt/robocode/robots/sample/Corners.java
printf 'Fresh install passed the GUI, HTTP, and WebSocket checks on %s.\n' \
  "$(compose exec -T robocode-web uname -m)"

# Replace the disposable test setup with a volume shaped like the previous release.
compose down --volumes
compose run --rm --no-deps --entrypoint bash robocode-web -c '
  mkdir -p /opt/robocode/{config,robots,battles,libs}
  touch /opt/robocode/{config,robots,battles}/classroom-fixture
  touch /opt/robocode/libs/robocode.core-1.10.1.jar
'
compose up --detach --wait --wait-timeout 120
check_window
check_browser_endpoint
compose exec -T robocode-web bash -se <<'BASH'
  for dir in config robots battles; do
    test -f "/opt/robocode-runtime/$dir/classroom-fixture"
  done
  test -f /opt/robocode-runtime/libs/robocode.core-1.12.0.jar
  test ! -e /opt/robocode-runtime/libs/robocode.core-1.10.1.jar
BASH
echo 'Upgrade reused the classroom data and ran the verified version.'
