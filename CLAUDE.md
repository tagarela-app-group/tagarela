# CLAUDE.md — Tagarela

App Flutter (mobile) para aprender inglês. Este arquivo: regras gerais + mapa dos docs.

## Docs

Ler só o doc do assunto do pedido. Não ler todos por padrão.

| Doc | Assunto |
| --- | --- |
| `docs/PRODUCT.md` | Produto: problema, usuário, telas, escopo. |
| `docs/ARCHITECTURE.md` | Técnico: stack, pastas, dados, convenções de código. |
| `docs/DESIGN.md` | Design system: tokens, componentes, regras visuais. |

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
11. Task finalizada: commit + push na hora, sem perguntar. Mensagem sem `Co-Authored-By` nem outra assinatura de IA.
12. Git: trabalho na `develop`. `main` = prod, nunca commitar direto nela.
