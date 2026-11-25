FROM scratch AS installer

# Digest published by the Robocode release API for this exact installer.
ADD --checksum=sha256:4a78707acdbd0ef8e88ede7839b6088b6545f35721fb9242baded6b4ef81a0e3 https://github.com/robo-code/robocode/releases/download/v1.12.0/robocode-1.12.0-setup.jar /robocode-setup.jar

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jre \
    xvfb \
    x11-utils \
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

# Keep the runtime outside the volume used by earlier Compose installations.
RUN --mount=type=bind,from=installer,source=/robocode-setup.jar,target=/tmp/robocode-setup.jar \
    java -Djava.awt.headless=true -jar /tmp/robocode-setup.jar /opt/robocode-runtime silent \
    && test -x robocode.sh \
    && test -f libs/robocode.core-1.12.0.jar \
    && mkdir -p /opt/robocode/config \
    && mv battles robots roborumble /opt/robocode/ \
    && ln -s /opt/robocode/battles /opt/robocode/config /opt/robocode/robots /opt/robocode/roborumble .

COPY --chmod=755 scripts/entrypoint.sh /opt/scripts/entrypoint.sh

EXPOSE 6080

ENTRYPOINT ["/usr/bin/tini", "--", "/opt/scripts/entrypoint.sh"]
