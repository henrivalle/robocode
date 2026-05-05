FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jre-headless \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    novnc \
    websockify \
    python3 \
    ca-certificates \
    tini \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/robocode-runtime

COPY robocode-1.10.1-setup.jar /tmp/robocode-setup.jar
COPY scripts /opt/scripts

RUN chmod +x /opt/scripts/*.sh

EXPOSE 6080

ENTRYPOINT ["/usr/bin/tini", "--", "/opt/scripts/entrypoint.sh"]
