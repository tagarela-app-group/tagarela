# DESIGN — Tagarela

Código em `lib/design_system/`. Import único: `package:tagarela/design_system/design_system.dart`.

## Direção

Header violeta + body com topo arredondado (32). Assinatura: balão de fala (`AppRadius.bubble`: 3 cantos redondos, inferior esquerdo quase reto). Moderno, leve, cor só com significado.

## Cores

Ler via `context.colors` (`AppColors`, ThemeExtension). Cor fixa de marca: `AppPalette`.

| Cor | Significado |
| --- | --- |
| Violeta `primary` | Ação, header, botão +, foco, aba ativa |
| Manga `AppPalette.mango` | Palavra do dia, logo, avatar. Igual nos 2 temas |
| Âmbar `learning` | Aprendendo |
| Menta `mastered` | Dominado, sucesso |
| Coral / `alert` | Badge, erro, áudio |
| `contrast` / `onContrast` | Botão Apple: preto no claro, branco no escuro (regra da Apple) |
| Tinta `ink` / `inkSoft` | Texto principal / secundário |

- Superfícies: `bg` (body) → `surface` (card, tab bar, campo) → `surfaceAlt` (trilho, segmentado, sugestão). Borda: `line`.
- Tons suaves: `xxxSoft` (fundo) + `xxxText` (texto) para pílulas.
- `accent(AppAccent)`: tinta de ícone de grupo/origem (violet, coral, mint, mango, sky, pink).
- Manga, menta, âmbar, coral: texto tinta, nunca branco. Texto ≥ 4,5:1.

Escuro: header `#241D5C`, fundo `#0F0E17` (sem preto puro), primary clareia (`#8B7BFF`) com texto tinta, suaves = cor a 16–18%, sem sombra (elevação por tom + contorno 1 px). Tema segue o sistema.

## Tipografia (`AppText`)

- `AppFonts.display` Bricolage Grotesque (600–800): títulos, números, termos em inglês.
- `AppFonts.body` DM Sans (400–700): resto. Padrão do tema.

| Token | Tamanho/altura · peso | Uso |
| --- | --- | --- |
| `display` | 38/42 · 800 | Palavra do dia |
| `statLg` / `stat` | 44 / 30 · 800 | Números de resumo |
| `titleLg` | 28/34 · 700 | Título de tela |
| `titleMd` | 20/26 · 700 | Título de seção, termo capturado |
| `term` | 18/24 · 700 | Termo em lista |
| `titleSm` | 17/22 · 700 | Nome de grupo |
| `bodyLg` / `bodyMd` | 16/24 · 14/20 · 400 | Texto |
| `button` | 15/20 · 700 | Botão (16 no grande) |
| `label` | 13/18 · 700 | Rótulo de campo |
| `pill` | 12/16 · 700 | Status |
| `overline` / `tag` | 12 · 10 · 700 | Caixa alta |
| `caption` | 11/14 · 600 | Tab bar |

Estilos sem cor: herdam `ink`. Mudar cor com `copyWith(color:)`.

## Espaço, raio, movimento (`app_tokens.dart`)

- `AppSpacing.sN` = N × 4 (s1 4 … s14 56). Margem de tela `screen` = 20.
- `AppRadius`: xs 6 (tag) · sm 10 · md 16 (botão, campo) · lg 22 (card) · xl 28 (palavra do dia) · sheet 32 · pill · `bubble(r)`.
- `AppMotion`: fast 120 · base 200 · slow 320 ms. Curva `standard`; `spring` (easeOutBack) no arco. Troca de aba: a nova entra por cima da antiga (que fica opaca embaixo) com fade + subida leve (`slow`, `standard`). Estado das abas mantido.
- `AppBlur.scrim` 2: desfoque atrás do scrim.
- Sombra: `cardShadow`, `buttonShadow` (só primário grande), `fabShadow`. Vêm de `AppColors`.
- Toque mínimo 44.

## Ícones (`AppIcons`)

Material outlined/rounded, centralizado em `app_icons.dart`. Trocar pacote = mexer só lá. 22 em tab bar/header, 16–20 em linhas. Logo Apple: `AppIcons.apple`. Logo Google: imagem `assets/images/google.png` (colorido).

Balão de fala redondo: Material não tem. Usar `SpeechBubbleIcon` (desenhado, mesma API do `Icon`).

## Componentes

| Componente | Uso |
| --- | --- |
| `SheetPage` | Toda tela: header + body arredondado rolável |
| `PageHeader` | Título/subtítulo (+ leading/trailing) no header |
| `SectionHeader` | Título de seção + ação texto |
| `AppButton` | Variantes primary (ação principal, uma por tela), tonal, outline, ink (sobre manga), contrast (botão Apple), text. Tamanhos large 56, medium 48, small 44. `expand`, `leading`. `loading`: spinner 18 na cor do texto no lugar do `leading`, rótulo e cor da variante ficam, toque ignorado. Enquanto um botão carrega, os outros da tela ficam desabilitados |
| `AppIconButton` | Botão redondo de ícone. Variantes onHeader, ink, primary, ghost. `tooltip` obrigatório |
| `AppCard` | Superfície com sombra. `onTap` opcional. `color` próprio = sem sombra |
| `AppTextField` | Rótulo acima, ícone, halo no foco, `helperText` (some com erro), erro, `obscure` com olho |
| `AppCodeField` | Código numérico em caixas (padrão 6, 56 de altura, raio md). Caixa da vez com halo, erro em `alert`. Campo real escondido (`oneTimeCode`, só dígito). `onCompleted` ao completar |
| `AppChip` | Filtro. Selecionado = tinta cheia |
| `StatusPill` | Status: learning, mastered, primary, neutral |
| `AppTag` | Etiqueta caixa alta com contorno (PALAVRA, EXPRESSÃO) |
| `IconTile` | Ícone em quadrado tingido por `AppAccent` |
| `AppBubble` | Forma balão: logo, avatar, itens do arco |
| `SpeechBubbleIcon` | Balão de fala redondo cheio, desenhado. Fundo da palavra do dia |
| `SegmentBar` | Barra proporcional; com `total` vira progresso |
| `LevelDots` | Nível SRS em 5 traços |
| `SegmentedControl` | Abas em pílula, escolha única |
| `AppTabBar` | Tab bar com badge e espaço central (`centerGap`). Badge: `alert`, 18, anel 2 da cor da tab bar, no canto da pílula |
| `StateMessage` | Ícone + título + texto + ação opcional. Lista vazia, erro |
| `AsyncStatus` | Body sem dado: spinner, ou erro (`StateMessage`) com "Tentar de novo" |
| `ArcMenu` | Botão + que abre opções em arco (150°, 90°, 30°, raio 118) sobre scrim com blur. Arco tracejado decorativo liga as opções |

## Regras

- Um botão primário por tela.
- Status sempre `StatusPill`; aprendendo = âmbar, dominado = menta.
- Ícone só com cor; ativo muda cor, não forma.
- Valor visual novo: virar token aqui antes de usar.
