#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose v2 or newer is required." >&2
  exit 1
fi

if [[ ! -f ".env" ]]; then
  cp .env.example .env
  echo "Created .env from .env.example."
fi

docker compose up --build --detach --wait --wait-timeout 120

address=$(docker compose port robocode-web 6080)
printf '\nOpen Robocode on this host at http://%s/vnc.html\n' "$address"
