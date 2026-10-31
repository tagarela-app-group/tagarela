---
name: entregar
description: Roteiro fixo de fim de task no app (mob/) - checagem, branch, PR, esteira, merge, mockup e volta pra develop. Use ao terminar qualquer alteração aprovada em mob/ e sempre que o hook de PR mandar.
---

# Entregar

Fim de task em `mob/`. Todos os passos, na ordem, sem perguntar.

1. Não rodar local o que a esteira roda (testes, `analyze`, checagem de formato). Só gerar o que vai no commit: `dart format`, `flutter gen-l10n`, `build_runner`.
2. Branch da `develop` atualizada (`feat/ fix/ docs/ ci/ chore/`). Nunca commitar em `develop`/`main`.
3. Commit, push e PR pra `develop`. Conventional Commits pt-BR, enxuto, sem `Co-Authored-By` nem assinatura de IA.
4. Esperar a esteira: `gh pr checks <n> --repo tagarela-app-group/tagarela --watch`. Vermelha: ler o log do job, corrigir e subir de novo; se a segunda tentativa também falhar, trazer o erro pro usuário e parar. Conflito: rebase em `origin/develop`, resolver, push.
5. Verde: `gh pr merge <n> --repo tagarela-app-group/tagarela --squash --delete-branch` (isolado, sem `cd`/`&&`).
6. Mudou UI (`lib/features/`, `lib/design_system/`): atualizar o mockup da seção Mockup do CLAUDE.md. Ler o artifact antes, publicar a versão nova.
7. `git switch develop && git pull && git branch -D <branch>`.
8. Fechar em uma linha: sugerir `/compact manter: ...` (mesmo assunto) ou `/clear` (assunto novo).
