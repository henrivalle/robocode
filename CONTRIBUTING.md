# Contributing / Como contribuir

Issues and pull requests are welcome in English or Brazilian Portuguese. Describe the classroom or deployment problem, the expected behavior, and a reproducible test. Include Docker and Compose versions when they matter. Use fictional student information in examples and remove passwords, tokens, and personal details from logs or screenshots.

Issues e pull requests são bem-vindos em inglês ou português. Descreva o problema de sala de aula ou implantação, o comportamento esperado e como reproduzi-lo. Inclua as versões do Docker e do Compose quando forem relevantes. Use dados fictícios de estudantes nos exemplos e retire senhas, tokens e informações pessoais de logs ou capturas de tela.

Run / Execute:

```bash
shellcheck deploy-linux.sh scripts/entrypoint.sh tests/*.sh
bash tests/compose-config.sh
bash tests/smoke.sh
```

Use Python 3, `curl`, ShellCheck and the Docker prerequisites listed in the README. For changes involving Robocode core or features built into the game, use the [upstream Robocode repository](https://github.com/robo-code/robocode).

Use Python 3, `curl`, ShellCheck e os pré-requisitos de Docker descritos no README. Para alterações no Robocode em si ou nos recursos do jogo, use o [repositório oficial do Robocode](https://github.com/robo-code/robocode).
