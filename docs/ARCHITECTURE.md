# ARCHITECTURE — Tagarela

## Stack

- Flutter 3.44 / Dart 3.12. Só Android e iOS.
- Zero dependência externa. HTTP via `dart:io`. Estado via `ChangeNotifier` + `setState`. Navegação com `Navigator`.
- Fontes embutidas em `assets/fonts/` (sem pacote, funciona offline).
- Java 21 fixado no projeto via `mise.toml`. Gradle 9 exige JVM 17+.

## Pastas

```
lib/
  main.dart              runApp com AppScope
  app/                   MaterialApp, shell de abas (HomeShell), AppScope (stores)
  design_system/         tokens, tema, componentes. Ver DESIGN.md
    design_system.dart   barrel: único import do DS
  data/                  models.dart, api_client.dart, store.dart
    services/            1 por recurso da API (sem estado)
    stores/              estado compartilhado (1 por recurso)
  features/<feature>/    <feature>_page.dart + widgets/ (só da feature)
assets/
  fonts/                 Bricolage Grotesque + DM Sans (TTF estático) + OFL
  images/                google.png (botão de login)
server/                  db.json: mock da API (json-server). Ver API
test/                    espelha lib/. Ver Testes
docs/                    PRODUCT, ARCHITECTURE, DESIGN
```

## Onde colocar

- Widget usado em 2+ features ou genérico: `design_system/components/` (perguntar antes).
- Widget só de uma feature: `features/<feature>/widgets/`.
- Subwidget usado só em um arquivo: classe privada (`_Nome`) no mesmo arquivo.
- Modelo de dados: `data/models.dart` (com `fromJson`). Conta sobre dados (totais, filtros): no model, não no widget.
- Chamada de API: `data/services/`. Estado compartilhado: `data/stores/`. Dado fake: `server/db.json`.

## Navegação

- `LoginPage` → `pushReplacement` → `HomeShell`.
- `HomeShell`: `IndexedStack` (Início, Vocabulário, Inbox, Perfil) + `AppTabBar` + `ArcMenu`.
- Grupo: `push` de `GroupPage` (tela cheia, sem tab bar).
- Sair: `pushAndRemoveUntil` → `LoginPage`.

## Dados e estado

Fluxo: tela → store → service → `ApiClient` → API.

- `ApiClient`: único ponto de rede. JSON, timeout 10 s. Status ≥ 400 vira `ApiException`.
- Service: chama endpoint e converte JSON em model. Sem estado. Trocar de API = mexer só em service (e `fromJson`).
- Store: `Store<T>` (`ChangeNotifier`) guarda `data` e `error` de um recurso. `data` e `error` nulos = carregando. Ação (ex.: `InboxStore.accept`) chama service e atualiza `data`.
- `AppScope`: cria os stores; tela pega via `AppScope.of(context)`. `loadAll()` no login.
- Tela: `ListenableBuilder` no store. Sem `data`: `AsyncStatus` (carregando, ou erro com "Tentar de novo"). Vários stores: `<Store>[...]` + `isReady` / `error` / `retry`.
- Estado só da tela (aba, filtro, campo): `setState`.

## API

- URL base: `--dart-define=API_URL=...`. Padrão `http://10.0.2.2:3000` (emulador Android enxerga o PC em 10.0.2.2).
- Mock: `npx json-server server/db.json` (porta 3000). Celular físico: `API_URL=http://<IP do PC>:3000`.
- Rotas: `GET /user`, `/stats`, `/wordOfDay`, `/groups?_embed=terms`, `/inbox`. `POST /terms`. `DELETE /inbox/:id`.
- IDs sempre string (json-server v1 gera string).
- http sem TLS só no debug (`usesCleartextTraffic` em `android/app/src/debug`). Release: só https. iOS (ATS): não configurado.
- Online: hospedar o db.json (ex.: my-json-server lê `db.json` na raiz de um repo GitHub; só leitura) e passar a URL https.
- `InboxService.accept` faz 2 chamadas (POST termo + DELETE item) por limite do json-server. API real: 1 endpoint.

## Layout de tela

- Toda tela = `SheetPage(header, children)`. Já traz Scaffold, safe area, scroll, topo arredondado.
- `HomeShell` troca `MediaQuery.padding.bottom` das abas por `ArcMenu.overhang` (espaço do botão +).

## Convenções

- Import sempre `package:tagarela/...`. Feature importa DS só via `design_system.dart`.
- Aspas simples. Lints: `flutter_lints` + `always_use_package_imports` + `prefer_single_quotes`.
- Texto da UI em pt-BR, direto no widget. Rótulo de enum no próprio enum (`TermKind.label`).
- Arquivo `snake_case.dart`, um widget público por arquivo.
- Antes de entregar: `dart format lib test`, `flutter analyze` sem issues, `flutter test` verde.

## Testes

- Pasta `test/` espelha `lib/`: `lib/x/y.dart` → `test/x/y_test.dart`.
- Só `flutter_test` (vem no SDK). Sem pacote de mock: fake manual.
- API fake: `test/helpers/fake_api_client.dart`. Usa `server/db.json` em memória (GET, `_embed`, POST, DELETE). `failing = true` simula erro. Services, stores e telas testam sobre ela.
- Montar widget via `test/helpers/pump_app.dart`: `pumpPage` (tela com tema + `AppScope` com stores carregados; `load: false` = carregando), `pumpComponent` (componente dentro de `Scaffold`). Tela de teste: 800x1600.
- Contrato do `db.json`: `test/server/db_json_test.dart`.
- Unit test: model, service, lógica pura.
- Widget test: componente e tela com comportamento (toque, estado, navegação).
- Código novo ou alterado: teste junto. Bug corrigido: teste que reproduz o bug.
- Cobertura: `flutter test --coverage` → `coverage/lcov.info`. Toda lógica coberta; tela cobre fluxo principal.

## Dependências

Antes de adicionar pacote: checar pub.dev (likes, último publish), issues abertas (build/toolchain). Contar ao usuário antes de instalar. Plugin nativo ou pacote pouco mantido: perguntar.

## Git e CI

- Branches: `main` = produção. `develop` = integração. Cada mudança = branch nova a partir da `develop`: `feat/`, `fix/`, `docs/`, `ci/`, `chore/` + nome curto.
- Fluxo: branch → commit → push → PR pra `develop`. Esteira verde → squash merge, branch apagada. Release: PR `develop` → `main` (merge commit), aprovado pelo usuário.
- Esteira: `.github/workflows/ci.yml`. Roda em todo PR e push na `develop`/`main`.
  - Formato, análise e testes: `flutter pub get --enforce-lockfile`, `dart format --set-exit-if-changed lib test`, `flutter analyze`, `flutter test --coverage`. Cobertura no resumo da rodada + artefato `cobertura`.
  - Build Android: `flutter build apk --release` (chave de debug). APK no artefato `apk`, 7 dias.
  - Build iOS: `flutter build ios --release --no-codesign`. Só PR/push na `main` (macOS lento).
- Flutter da esteira = `FLUTTER_VERSION` no workflow. Subiu o Flutter local: subir lá junto.
- Antes do push, rodar local: `dart format lib test`, `flutter analyze`, `flutter test`.
