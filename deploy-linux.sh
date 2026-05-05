#!/usr/bin/env bash

set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker nao encontrado. Instale Docker Engine antes de continuar." >&2
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  echo "Docker Compose nao encontrado. Instale o plugin docker compose." >&2
  exit 1
fi

if [[ ! -f ".env" ]]; then
  cp .env.example .env
  echo ".env criado a partir de .env.example. Ajuste a senha antes de abrir para a internet."
fi

${COMPOSE_CMD} build
${COMPOSE_CMD} up -d

echo
echo "Robocode publicado."
echo "Acesse no navegador: http://SEU_SERVIDOR:$(awk -F= '/^ROBOCODE_WEB_PORT=/{print $2}' .env)"
