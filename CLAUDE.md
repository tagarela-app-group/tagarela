# CLAUDE.md — Tagarela

App Flutter (mobile) para aprender inglês. Este arquivo: regras gerais + mapa dos docs.

## Docs

Ler só o doc do assunto do pedido. Não ler todos por padrão.

| Doc | Assunto |
| --- | --- |
| `docs/PRODUCT.md` | Produto: problema, usuário, telas, escopo. |
| `docs/ARCHITECTURE.md` | Técnico: stack, pastas, dados, convenções de código. |
| `docs/DESIGN.md` | Design system: tokens, componentes, regras visuais. |

Mockup (fonte visual): https://claude.ai/artifact/36zen91FwEpmPP1UFrEFrR. Canvas Design: telas claro/escuro (`Main.dc.html` tem todas) + board `DesignSystem.dc.html`. Ler e publicar via Artifact tool.

## Regras

1. Início de chat novo: ativar skill `caveman` (nível `full`).
2. Cada coisa no seu lugar. Conteúdo novo vai no doc do assunto. Doc não repete outro doc.
3. Docs: só o necessário. Objetivo, estilo caveman, sem perder informação.
4. UI: reutilizar componente de `lib/design_system/` antes de criar algo.
5. Componente novo no design system: perguntar ao usuário antes de criar.
6. Cor, fonte, espaço, raio, ícone: sempre token (`docs/DESIGN.md`). Nunca valor solto.
7. Mudou estrutura, componente ou tela: atualizar o doc do assunto junto.
8. Seguir sempre boas práticas de código, estrutura e arquitetura.
9. Pedido quebra regra ou boa prática: avisar usuário antes de fazer. Dizer qual regra e propor alternativa.
10. Código novo ou alterado (model, service, lógica, feature): teste junto. Regras em `docs/ARCHITECTURE.md` (Testes).
11. Task finalizada: branch própria + commit + push + PR pra `develop`, na hora, sem perguntar. Fluxo em `docs/ARCHITECTURE.md` (Git e CI). Commit e PR sem `Co-Authored-By` nem outra assinatura de IA.
12. Merge: PR pra `develop` com esteira verde = eu faço. PR `develop` → `main` (prod) = só o usuário aprova. Nunca commitar direto na `develop` nem na `main`.
13. Mudança no app que afete o visual: atualizar o mockup junto, sempre. Mockup = registro fiel do app.
