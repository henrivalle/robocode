# Robocode Classroom

[Português (Brasil)](README.pt-BR.md)

Run Classic Robocode in a browser for Java programming labs. A Docker service starts the game on a virtual desktop and serves it via noVNC. Students need a browser. The host needs Docker Engine 28+ with BuildKit and Docker Compose v2 or newer.

## Start a lab

```bash
cp .env.example .env
./deploy-linux.sh
```

Open [http://127.0.0.1:6080/vnc.html](http://127.0.0.1:6080/vnc.html) on the Docker host and choose **Connect**. Set `ROBOCODE_WEB_PORT` in `.env` if port 6080 is in use. Change `ROBOCODE_GEOMETRY` to set the virtual desktop size.

The service listens on host loopback. For an instructor connecting to a remote host, use an SSH tunnel, for example `ssh -N -L 6080:127.0.0.1:6080 USER@HOST`. For classroom access, put the endpoint behind an authenticated HTTPS reverse proxy that passes WebSocket connections. Each instance is one shared desktop. Assign a separate Compose project and host port per team when teams need independent sessions. Offer the service to trusted users and run untrusted student code only in an environment designed for that purpose.

```bash
ROBOCODE_WEB_PORT=6081 docker compose -p class-a up --build -d --wait
docker compose -p class-a logs -f
docker compose -p class-a down
```

## Data and upgrades

The `robocode-data` named volume keeps `robots`, `battles`, `config`, and `roborumble` data. Keep the same Compose project name when upgrading an existing deployment. The image uses the upstream Robocode 1.12.0 installer with a pinned SHA-256 digest. Runtime files come from the image, while the existing volume supplies class data. Robot files, settings, and battles in the documented directories are reused. Keep a backup of your volume before upgrading. `docker compose down` keeps the volume and `docker compose down --volumes` removes it.

Run `bash tests/compose-config.sh` to check port binding and `bash tests/smoke.sh` to verify a fresh install, the browser endpoint, and upgrade with a disposable legacy volume. See [Contributing](CONTRIBUTING.md) for test requirements and [third-party notices](THIRD_PARTY_NOTICES.md) for upstream licensing.
