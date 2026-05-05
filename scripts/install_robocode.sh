#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/opt/robocode"
SETUP_JAR="/tmp/robocode-setup.jar"
OPTIONS_FILE="/tmp/robocode-install.options"

if [[ -x "${INSTALL_DIR}/robocode.sh" ]]; then
  exit 0
fi

echo "Generating installer options template..."
java -jar "${SETUP_JAR}" -options-template "${OPTIONS_FILE}"

# We pin install path and keep all other generated defaults intact.
if awk '/^INSTALL_PATH=/{found=1} END{exit !found}' "${OPTIONS_FILE}"; then
  sed -i "s|^INSTALL_PATH=.*|INSTALL_PATH=${INSTALL_DIR}|" "${OPTIONS_FILE}"
else
  printf "\nINSTALL_PATH=%s\n" "${INSTALL_DIR}" >> "${OPTIONS_FILE}"
fi

echo "Running unattended Robocode installation..."
java -jar "${SETUP_JAR}" -options "${OPTIONS_FILE}" -auto

if [[ ! -x "${INSTALL_DIR}/robocode.sh" ]]; then
  echo "Installer finished, but robocode.sh was not created in ${INSTALL_DIR}." >&2
  exit 1
fi

echo "Robocode installed in ${INSTALL_DIR}."
