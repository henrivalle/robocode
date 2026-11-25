# Robocode Classroom

[English](README.md)

Execute o Robocode clássico no navegador para laboratórios de programação em Java. Um serviço Docker inicia o jogo em um desktop virtual e o disponibiliza via noVNC. Os estudantes precisam de um navegador. O servidor precisa de Docker Engine 28+ com BuildKit e Docker Compose v2 ou posterior.

## Iniciar um laboratório

```bash
cp .env.example .env
./deploy-linux.sh
```

Abra [http://127.0.0.1:6080/vnc.html](http://127.0.0.1:6080/vnc.html) no host Docker e escolha **Connect**. Configure `ROBOCODE_WEB_PORT` no `.env` se a porta 6080 estiver em uso. Use `ROBOCODE_GEOMETRY` para ajustar o tamanho do desktop virtual.

O serviço escuta na interface local do host. Para o professor se conectar a um servidor remoto, use um túnel SSH, por exemplo `ssh -N -L 6080:127.0.0.1:6080 USUARIO@SERVIDOR`. Para acesso da turma, coloque o serviço atrás de um proxy reverso HTTPS com autenticação e suporte a WebSocket. Cada instância oferece um desktop compartilhado. Use um projeto Compose e uma porta por equipe se elas precisarem de sessões independentes. Disponibilize o serviço a usuários de confiança e execute código não confiável em um ambiente preparado para isso.

```bash
ROBOCODE_WEB_PORT=6081 docker compose -p turma-a up --build -d --wait
docker compose -p turma-a logs -f
docker compose -p turma-a down
```

## Dados e atualizações

O volume nomeado `robocode-data` guarda `robots`, `battles`, `config` e `roborumble`. Mantenha o mesmo nome de projeto Compose ao atualizar uma instalação existente. A imagem usa o instalador oficial do Robocode 1.12.0 com SHA-256 fixado. Os arquivos de execução vêm da imagem e o volume existente fornece os dados da turma. Os robôs, configurações e batalhas nesses diretórios são reaproveitados. Faça backup do volume antes de atualizar. `docker compose down` mantém o volume e `docker compose down --volumes` o remove.

Execute `bash tests/compose-config.sh` para verificar as portas e `bash tests/smoke.sh` para testar a instalação limpa, o acesso pelo navegador e a atualização com um volume descartável. Veja os requisitos de teste em [Como contribuir](CONTRIBUTING.md) e a licença do Robocode em [Avisos de terceiros](THIRD_PARTY_NOTICES.md).
