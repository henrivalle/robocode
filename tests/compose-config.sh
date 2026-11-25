#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

check_port() {
  local requested_port=$1 expected_port=$2
  ROBOCODE_WEB_PORT="$requested_port" docker compose --env-file /dev/null config --format json |
    python3 -c '
import json
import sys

service = json.load(sys.stdin)["services"]["robocode-web"]
[port] = service["ports"]
assert port.get("host_ip") == "127.0.0.1", port
assert str(port["published"]) == sys.argv[1], port
assert port["target"] == 6080, port
assert "container_name" not in service, "Fixed name prevents multiple Compose projects"
' "$expected_port"
}

check_port '' 6080
check_port 16080 16080
