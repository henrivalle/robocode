# Robocode via navegador (Linux)

Este projeto publica o Robocode em um servidor Linux para uso no navegador, sem instalacao local nos computadores dos alunos.

## Como funciona

- O Robocode roda em um container Docker com desktop virtual (`Xvfb`).
- A interface grafica do Robocode e exposta por `noVNC`.
- Os alunos acessam usando URL HTTP/HTTPS.

## Requisitos no servidor

- Linux com Docker Engine instalado
- Docker Compose (`docker compose`)
- Porta TCP liberada (padrao `6080`)

## Deploy rapido

1. Copie os arquivos deste diretorio para o servidor.
2. Ajuste a senha no arquivo `.env` (ou gere com o exemplo):

```bash
cp .env.example .env
```

3. Rode o deploy:

```bash
chmod +x deploy-linux.sh scripts/*.sh
./deploy-linux.sh
```

4. Abra no navegador:

```text
http://SEU_SERVIDOR:6080/vnc.html
```

## Operacao

- Subir: `docker compose up -d`
- Parar: `docker compose down`
- Logs: `docker compose logs -f`

## Recomendacoes para uso com alunos

- Publique por HTTPS atras de um proxy reverso (Nginx/Caddy/Traefik).
- Troque a senha padrao no `.env`.
- Se varios alunos usarem ao mesmo tempo, execute multiplas instancias em portas diferentes.
- O volume `robocode-data` persiste configuracoes e robos entre reinicios.

## Observacao importante

Este setup instala automaticamente o Robocode no primeiro start do container usando o instalador oficial `robocode-1.10.1-setup.jar`.
