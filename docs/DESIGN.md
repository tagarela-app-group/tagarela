# DESIGN — Tagarela

Código em `lib/design_system/`. Import único: `design_system.dart`. Valor exato: no código.

## Direção

Header violeta + body com topo arredondado. Assinatura: balão de fala (`AppRadius.bubble`). Leve, cor só com significado. Tema segue o sistema. Escuro: sem preto puro, sem sombra (elevação por tom + contorno).

## Cores

Ler via `context.colors`. Cor fixa de marca: `AppPalette`.

| Cor | Significado |
| --- | --- |
| Violeta `primary` | Ação, header, botão +, foco |
| Manga `AppPalette.mango` | Palavra do dia, logo, avatar |
| Âmbar `learning` | Aprendendo |
| Menta `mastered` | Dominado, sucesso |
| Coral `alert` | Erro, badge |
| `contrast` | Botão Apple |
| `ink` / `inkSoft` | Texto principal / secundário |

- Superfície: `bg` → `surface` → `surfaceAlt`. Borda: `line`. Pílula: `xxxSoft` + `xxxText`. Grupo: `accent(AppAccent)`.
- Manga, menta, âmbar, coral: texto tinta, nunca branco. Contraste ≥ 4,5:1.

## Tipo, espaço, forma

- `AppText`: Bricolage Grotesque (título, número, termo em inglês) + DM Sans (resto). Estilo sem cor herda `ink`. Cor via `copyWith`.
- `AppSpacing.sN` = N × 4. Margem de tela 20. `AppRadius`, `AppMotion`, sombras de `AppColors`. Toque mínimo 44.
- Ícone: só `AppIcons`. Balão de fala: `SpeechBubbleIcon`.

## Componentes

Antes de criar, procurar em `components/`.

- Tela: `SheetPage`, `PageHeader`, `SectionHeader`, `StateMessage`, `AsyncStatus`.
- Ação: `AppButton`, `AppIconButton` (`tooltip` obrigatório), `ArcMenu` (botão +).
- Conteúdo: `AppCard`, `OptionRow`, `IconTile`, `AppBubble`, `TermChip`, `StatusPill`, `AppTag`, `LevelDots`, `SegmentBar`.
- Entrada: `AppTextField`, `AppCodeField`, `AppChip`, `SegmentedControl`, `AppCheckbox`, `IconPicker`, `AccentPicker`.
- Camada: `AppSheet`, `AppToast`, `AppTabBar`.

## Regras

- Um botão primário por tela.
- Status sempre `StatusPill`: aprendendo âmbar, dominado menta.
- Valor visual novo: vira token antes de usar.
- Aviso com ação: `AppToast`. Erro simples: `SnackBar` só com texto.

## Mockup

Abas por assunto: Conta, Início, Captura, Inbox, Vocabulário, Perfil, Design system, Propostas.

- Linha de cima: tema claro. Linha de baixo: escuro. Mesma coluna = mesma tela. Estados na ordem do fluxo.
- Ideia não aprovada: aba Propostas, com nota laranja. Entrou no app: vai pra aba do assunto.
- Nenhuma tela some enquanto existir no app.
- Board do design system: uma parte por aba. Componentes por família.
