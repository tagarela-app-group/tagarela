# ARCHITECTURE — Tagarela

## Stack

- Flutter 3.44 / Dart 3.12. Só Android e iOS.
- HTTP via `dart:io`. Estado via `ChangeNotifier` + `setState`. Navegação com `Navigator`.
- Dependências: só 3 plugins nativos, da conta. `google_sign_in` (login Google), `sign_in_with_apple` (login Apple), `flutter_secure_storage` (refresh token no Keychain/Keystore). Fora isso, zero pacote.
- Fontes embutidas em `assets/fonts/` (sem pacote, funciona offline).
- Java 21 fixado no projeto via `mise.toml`. Gradle 9 exige JVM 17+.
- `kotlin.incremental=false` em `android/gradle.properties`: no Windows, projeto e pub cache em drives diferentes quebram o cache incremental do Kotlin ("Could not close incremental caches" no plugin `google_sign_in_android`).

## Pastas

```
lib/
  main.dart              runApp com AppScope
  app/                   MaterialApp, shell de abas (HomeShell), AppScope (stores)
  design_system/         tokens, tema, componentes. Ver DESIGN.md
    design_system.dart   barrel: único import do DS
  data/                  models.dart, api_client.dart, store.dart
    social_sign_in.dart  único ponto que conhece google_sign_in e sign_in_with_apple
    token_storage.dart   único ponto que conhece flutter_secure_storage
    services/            1 por recurso da API (sem estado)
    stores/              estado compartilhado (1 por recurso)
  features/<feature>/    <feature>_page.dart + widgets/ (só da feature)
  features/auth/         login, cadastro, código, esqueci senha, nova senha + auth_form.dart (mixin de envio)
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

- Início: `AuthGate` restaura a sessão (splash enquanto isso). Com sessão → `HomeShell`. Sem → `LoginPage`.
- Entrou (login, código, nova senha, Google, Apple): `HomeShell.open` = `loadAll()` + `pushAndRemoveUntil` (sem voltar).
- Login → `push` de Cadastro / Esqueci a senha. Etapa pendente → `push` da tela de código. Voltar = `pop`.
- `HomeShell`: `IndexedStack` (Início, Vocabulário, Inbox, Perfil) + `AppTabBar` + `ArcMenu`.
- Grupo: `push` de `GroupPage` (tela cheia, sem tab bar).
- Sair: `AuthStore.logout()` + `pushAndRemoveUntil` → `LoginPage`.

## Dados e estado

Fluxo: tela → store → service → `ApiClient` → API.

- `ApiClient`: único ponto de rede. JSON, timeout 10 s. Status ≥ 400 vira `ApiException`.
- Service: chama endpoint e converte JSON em model. Sem estado. Trocar de API = mexer só em service (e `fromJson`).
- Store: `Store<T>` (`ChangeNotifier`) guarda `data` e `error` de um recurso. `data` e `error` nulos = carregando. Ação (ex.: `InboxStore.accept`) chama service e atualiza `data`.
- `AppScope`: cria os stores; tela pega via `AppScope.of(context)`. `loadAll()` ao entrar. `AuthStore` vem pronto de fora (`main.dart`), pra teste trocar API, storage e login social.
- `AuthStore` (`ChangeNotifier`, fora do `Store<T>`): guarda só o refresh token (`isSignedIn`). Método por fluxo, devolve `AuthResult`: `AuthSignedIn` (salva token) ou `AuthPending` (etapa + session token, passado pra tela seguinte). Erro da API: `AuthException` (mensagem por campo, `null` = geral).
- `restore()`: refresh no início. Recusado → apaga token. Sem rede → entra com o token salvo.
- `logout()`: apaga o token na hora. Depois tenta refresh + `DELETE` da sessão na API (falhou = ignora).
- Tela de auth: mixin `AuthForm` (`submit` com `busy`, erro do campo no `AppTextField`, erro geral ou de campo que a tela não tem em `SnackBar`, sem rede = "Sem conexão...").
- Tela: `ListenableBuilder` no store. Sem `data`: `AsyncStatus` (carregando, ou erro com "Tentar de novo"). Vários stores: `<Store>[...]` + `isReady` / `error` / `retry`.
- Estado só da tela (aba, filtro, campo): `setState`.

## API

Duas URLs: dados no mock, conta na API Django.


- URL base: `--dart-define=API_URL=...`. Padrão `http://10.0.2.2:3000` (emulador Android enxerga o PC em 10.0.2.2).
- Mock: `npx json-server server/db.json` (porta 3000). Celular físico: `API_URL=http://<IP do PC>:3000`.
- Rotas: `GET /user`, `/stats`, `/wordOfDay`, `/groups?_embed=terms`, `/inbox`. `POST /terms`. `DELETE /inbox/:id`.
- IDs sempre string (json-server v1 gera string).
- http sem TLS só no debug (`usesCleartextTraffic` em `android/app/src/debug`). Release: só https. iOS (ATS): não configurado.
- Online: hospedar o db.json (ex.: my-json-server lê `db.json` na raiz de um repo GitHub; só leitura) e passar a URL https.
- `InboxService.accept` faz 2 chamadas (POST termo + DELETE item) por limite do json-server. API real: 1 endpoint.

Conta (`AuthService`, API Django com allauth headless; detalhe dos fluxos em `api/docs/ARCHITECTURE.md`, seção Auth):

- URL: `--dart-define=AUTH_URL=...`. Padrão `http://10.0.2.2:8000` (compose do `api/`). Base das rotas: `/api/auth/app/v1`.
- `ApiClient.send`: status + corpo sem lançar em 4xx (allauth usa 401 pra etapa pendente). `get`/`post`/`delete` seguem lançando `ApiException`. Corpo sempre com `Content-Length`: o `runserver` do Django ignora corpo chunked (o padrão do `HttpClient` do Dart) e a API veria o POST vazio.
- Rotas: `POST auth/login`, `auth/signup`, `auth/email/verify`, `auth/email/verify/resend`, `auth/password/request`, `auth/password/reset`, `auth/provider/token`, `tokens/refresh`. `GET auth/password/reset` (valida código), `config` (client ID dos providers). `DELETE auth/session` (sair).
- Header: etapa pendente = `X-Session-Token`. Logado = `Authorization: Bearer`. Código de reset = `X-Password-Reset-Key`.
- Mensagem: a da API (pt-BR). 429 → "Muitas tentativas...". 409/410 → "Essa etapa expirou...". 5xx → `ApiException`.
- Google: o client ID web vem da API (`GET config`, provider `google`), que lê o `GOOGLE_CLIENT_ID` do `.env` do backend. É o `serverClientId` do `google_sign_in` e o `aud` do id_token. Nada a passar no `flutter run`. Sem client ID na API, o botão avisa "Esse login não está disponível agora.". iOS: `--dart-define=GOOGLE_IOS_CLIENT_ID=<client ID iOS>` + URL scheme com o client ID iOS invertido no `Info.plist` (falta: precisa do ID). Android: client OAuth Android com o SHA-1 da chave no Google Cloud.
- Apple: só iOS (botão some no Android). `APPLE_CLIENT_ID` = bundle ID `com.tagarela.tagarela` (padrão; mesmo `APPLE_CLIENT_ID` do backend). Entitlement `com.apple.developer.applesignin` em `ios/Runner/Runner.entitlements`; no Xcode, time com a capability Sign in with Apple.
- Token: refresh no `flutter_secure_storage` (chave `refresh_token`). Access não é guardado: nenhuma rota de dados pede login ainda.

## Layout de tela

- Toda tela = `SheetPage(header, children)`. Já traz Scaffold, safe area, scroll, topo arredondado.
- `HomeShell` troca `MediaQuery.padding.bottom` das abas por `ArcMenu.overhang` (espaço do botão +). Área segura inferior fica com a tab bar.
- Teclado: `HomeShell` com `resizeToAvoidBottomInset: false`. Cada aba (`SheetPage`) cuida do teclado; a tab bar fica parada.

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
- Conta: `test/helpers/fake_auth.dart`. `FakeAuthApi` (resposta por rota `MÉTODO caminho`, padrão = caminho feliz; `errors`, `pending`, `signedIn` montam resposta; `error` simula sem rede; `last(rota)` = request enviado), `FakeTokenStorage`, `FakeSocialSignIn` (token ou `null` = cancelado), `fakeAuthStore()`. `pumpPage(auth: ...)`. Campo por rótulo: `textField('E-mail')`. iOS: `variant: TargetPlatformVariant.only(TargetPlatform.iOS)`.
- Unit test: model, service, lógica pura.
- Widget test: componente e tela com comportamento (toque, estado, navegação).
- Código novo ou alterado: teste junto. Bug corrigido: teste que reproduz o bug.
- Cobertura: `flutter test --coverage` → `coverage/lcov.info`. Toda lógica coberta; tela cobre fluxo principal.

## Dependências

Antes de adicionar pacote: checar pub.dev (likes, último publish), issues abertas (build/toolchain). Contar ao usuário antes de instalar. Plugin nativo ou pacote pouco mantido: perguntar.

Hoje: `google_sign_in` ^7.2, `sign_in_with_apple` ^8.2 (exige Flutter ≥3.44), `flutter_secure_storage` ^11.2. iOS via Swift Package Manager (sem Podfile).

## Git e CI

- Branches: `main` = produção. `develop` = integração. Cada mudança = branch nova a partir da `develop`: `feat/`, `fix/`, `docs/`, `ci/`, `chore/` + nome curto.
- Fluxo: branch → commit → push → PR pra `develop`. Esteira verde → squash merge, branch apagada. Release: PR `develop` → `main` (merge commit), aprovado pelo usuário.
- Esteira: `.github/workflows/ci.yml`. Roda em todo PR e push na `develop`/`main`. Push novo no mesmo PR cancela a rodada anterior.
  - Formato, análise e testes: `flutter pub get --enforce-lockfile`, `dart format --set-exit-if-changed lib test`, `flutter analyze`, `flutter test --coverage`. Cobertura no resumo da rodada + artefato `cobertura`.
  - Dependências vulneráveis: OSV-Scanner em todo lockfile do repo (`pubspec.lock`, `Podfile.lock`...). Versão fixa: o Google avisa que muda até em patch. Vulnerabilidade conhecida reprova o PR.
  - Build Android: `flutter build apk --release` (chave de debug). APK no artefato `apk`, 7 dias.
  - Build iOS: `flutter build ios --release --no-codesign`. Só PR/push na `main` (macOS lento).
- Flutter da esteira = `FLUTTER_VERSION` no workflow. Subiu o Flutter local: subir lá junto.
- GitHub (config do repo): Dependabot alerts + security updates (PR de correção sozinho), secret scanning + push protection (bloqueia push com segredo).
- Antes do push, rodar local: `dart format lib test`, `flutter analyze`, `flutter test`.
