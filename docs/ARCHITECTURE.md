# ARCHITECTURE — Tagarela

## Stack

- Flutter 3.44 / Dart 3.12. Só Android e iOS.
- HTTP via `dart:io`. Estado via `ChangeNotifier` + `setState`. Navegação com `Navigator`.
- Dependências: conta (`google_sign_in`, `sign_in_with_apple`, `flutter_secure_storage`), captura offline (`drift` + `drift_flutter`: SQLite local; `path_provider`: pasta do app) e `audioplayers` (ouvir a gravação). Fora isso, zero pacote. Ver Dependências.
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
    database.dart        único ponto que conhece drift: tabelas captures e capture_cursors (+ database.g.dart gerado)
    media_storage.dart   único ponto que conhece path_provider: foto/áudio na pasta do app
    audio_playback.dart  único ponto que conhece audioplayers: um player pro app todo (toca um áudio por vez)
    services/            1 por recurso da API (sem estado)
    stores/              estado compartilhado (1 por recurso)
  features/<feature>/    <feature>_page.dart + widgets/ (só da feature)
  features/auth/         login, cadastro, código, esqueci senha, nova senha + auth_form.dart (mixin de envio)
assets/
  fonts/                 Bricolage Grotesque + DM Sans (TTF estático) + OFL
  images/                google.png (botão de login)
test/                    espelha lib/. Ver Testes
docs/                    PRODUCT, ARCHITECTURE, DESIGN
build.yaml               opção do drift_dev (data como texto ISO, mantém fuso e microssegundo)
```

## Onde colocar

- Widget usado em 2+ features ou genérico: `design_system/components/` (perguntar antes).
- Widget só de uma feature: `features/<feature>/widgets/`.
- Subwidget usado só em um arquivo: classe privada (`_Nome`) no mesmo arquivo.
- Modelo de dados: `data/models.dart` (com `fromJson`). Conta sobre dados (totais, filtros): no model, não no widget.
- Chamada de API: `data/services/`. Estado compartilhado: `data/stores/`. Dado de exemplo pra teste: `test/helpers/fixtures.dart`.

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
- Store: `Store<T>` (`ChangeNotifier`) guarda `data` e `error` de um recurso. `data` e `error` nulos = carregando. Ação (ex.: `CaptureStore.confirm`) grava, chama service e atualiza `data`.
- Recurso que a API ainda não tem (Home: estatística e palavra do dia; Vocabulário: grupos e termos): store sem service, fonte local vazia (`HomeStore.empty`, `VocabularyStore()`). Teste passa dados no construtor. Tela some com o card sem dado (palavra do dia, revisão) e mostra estado vazio (Vocabulário). API ganhou o recurso: store volta a chamar service.
- `AppScope`: guarda os stores e o `AudioPlayback`; tela pega via `AppScope.of(context)`. `loadAll()` ao entrar: limpa mídia vencida e carrega tudo. `AuthStore`, `CaptureStore` e `AudioPlayback` vêm prontos de fora (`main.dart`), pra teste trocar API, banco, mídia e player.
- Sessão expirada (refresh recusado no meio do uso, `AuthStore.sessionExpired`): `HomeShell` volta pro login e avisa "Sua sessão expirou. Entre de novo.". Sair pelo Perfil não marca.
- `AuthStore` (`ChangeNotifier`, fora do `Store<T>`): guarda só o refresh token (`isSignedIn`). Método por fluxo, devolve `AuthResult`: `AuthSignedIn` (salva token) ou `AuthPending` (etapa + session token, passado pra tela seguinte). Erro da API: `AuthException` (mensagem por campo, `null` = geral).
- `restore()`: refresh no início. Recusado → apaga token. Sem rede → entra com o token salvo.
- `logout()`: apaga o token na hora. Depois tenta refresh + `DELETE` da sessão na API (falhou = ignora).
- Tela de auth: mixin `AuthForm` (`submit` com `busy`, erro do campo no `AppTextField`, erro geral ou de campo que a tela não tem em `SnackBar`, sem rede = "Sem conexão...").
- Tela: `ListenableBuilder` no store. Sem `data`: `AsyncStatus` (carregando, ou erro com "Tentar de novo"). Vários stores: `<Store>[...]` + `isReady` / `error` / `retry`.
- Estado só da tela (aba, filtro, campo): `setState`.

### Captura (offline first)

- Fonte da verdade: banco local (`AppDatabase`). `CaptureStore` (`Store<List<Capture>>`) lê do banco; API é sincronização. Tela: Inbox.
- Dono: cada linha guarda o e-mail da conta (`AuthStore.user`). Outra conta no mesmo celular não vê nem envia. Sair não apaga nada.
- Criar: id UUID v4 gerado no app (`Random.secure`). Texto nasce `ready`; foto/áudio nasce `waiting_file` com o arquivo copiado pra `captures/<photo|audio>/<id>.<ext>` na pasta de documentos do app.
- Pendência (`Capture.pending`): `create`, `file`, `update`, `confirm`, `discard`. Ação grava local + marca pendência + tenta enviar na hora (sem rede: fica pendente, sem erro).
- Sincronizar só por ação da pessoa (decisão do produto, por enquanto): criar, editar, confirmar, descartar, `processNow` ("Processar agora") e `sync()` (puxar a lista). Sem timer, sem segundo plano. `processing` → `ready` só aparece puxando a lista.
- `sync()`: envia pendências em ordem (`create` → `file` → `update` → `confirm`; `discard` sozinho) e puxa mudanças (`GET captures?updated_since=<cursor>`, paginado por `cursor`). Cursor por dono em `capture_cursors` = maior `updated_at` vindo do pull (não do envio, pra não pular mudança de outro aparelho). Sem rede: lança, pendência fica. API recusa (4xx menos 401): larga só aquela etapa e segue.
- Merge (`Capture.merge`): servidor manda, menos o que está pendente no celular (texto/termos em `update`, status em `confirm`, descarte em `discard`). Arquivo local sempre fica.
- Descartar nunca enviada: só some do celular, sem chamar a API.
- Mídia: apagada só 30 dias depois de analisada ou descartada (`Capture.mediaRetention`, `cleanMedia`). Pendente, pronta ou com erro: nunca. Texto fica sempre.

## API

Uma URL só: API Django (`api/`). Sem mock.

- URL base: `--dart-define=API_URL=...`. Padrão `http://10.0.2.2:8000` (compose do `api/`; emulador Android enxerga o PC em 10.0.2.2). Celular físico: `API_URL=http://<IP do PC>:8000`.
- http sem TLS só no debug (`usesCleartextTraffic` em `android/app/src/debug`). Release: só https. iOS (ATS): não configurado.

Conta (`AuthService`, allauth headless; detalhe dos fluxos em `api/docs/ARCHITECTURE.md`, seção Auth):

- Base das rotas: `/api/auth/app/v1`. `AuthService` usa um `ApiClient` sem token; dados usam outro com `accessToken`.
- `ApiClient.send`: status + corpo sem lançar em 4xx (allauth usa 401 pra etapa pendente). `get`/`post`/`delete` seguem lançando `ApiException`. Corpo sempre com `Content-Length`: o `runserver` do Django ignora corpo chunked (o padrão do `HttpClient` do Dart) e a API veria o POST vazio.
- Rotas: `POST auth/login`, `auth/signup`, `auth/email/verify`, `auth/email/verify/resend`, `auth/password/request`, `auth/password/reset`, `auth/provider/token`, `tokens/refresh`. `GET auth/password/reset` (valida código), `config` (client ID dos providers). `DELETE auth/session` (sair).
- Header: etapa pendente = `X-Session-Token`. Logado = `Authorization: Bearer`. Código de reset = `X-Password-Reset-Key`.
- Mensagem: a da API (pt-BR). 429 → "Muitas tentativas...". 409/410 → "Essa etapa expirou...". 5xx → `ApiException`.
- Google: o client ID web vem da API (`GET config`, provider `google`), que lê o `GOOGLE_CLIENT_ID` do `.env` do backend. É o `serverClientId` do `google_sign_in` e o `aud` do id_token. Nada a passar no `flutter run`. Sem client ID na API, o botão avisa "Esse login não está disponível agora.". iOS: `--dart-define=GOOGLE_IOS_CLIENT_ID=<client ID iOS>` + URL scheme com o client ID iOS invertido no `Info.plist` (falta: precisa do ID). Android: client OAuth Android com o SHA-1 da chave no Google Cloud.
- Apple: só iOS (botão some no Android). `APPLE_CLIENT_ID` = bundle ID `com.tagarela.tagarela` (padrão; mesmo `APPLE_CLIENT_ID` do backend). Entitlement `com.apple.developer.applesignin` em `ios/Runner/Runner.entitlements`; no Xcode, time com a capability Sign in with Apple.
- Token: refresh no `flutter_secure_storage` (chave `refresh_token`). Access só na memória (`AuthStore.accessToken`): vem do login; sem ele (app reaberto) ou com `renew`, faz refresh. Pedidos juntos dividem um refresh só (refresh troca o par). Refresh recusado = desloga.
- `ApiClient(accessToken: auth.accessToken)`: manda `Authorization: Bearer` em toda chamada. 401 → renova uma vez e repete. `putFile`: multipart com `Content-Length` (mesmo motivo do corpo JSON).
- Captura: `/api/v1/captures` (criar, `PUT {id}/file`, `PATCH {id}`, `POST {id}/confirm`, `DELETE {id}`, lista com `updated_since`). Contrato em `api/docs/ARCHITECTURE.md`.
- Usuário: vem da API em `data.user` (`name`, `email`, `picture` = foto do Google). `AuthStore.user` guarda o do login e, ao abrir o app, busca `GET auth/session` depois do refresh. Fica salvo no `flutter_secure_storage` (chave `user`) pra aparecer offline; sair apaga. Home (saudação + avatar) e Perfil leem daqui.

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
- Escopo de teste: `testScope(child: ...)` / `pumpPage(...)` em `test/helpers/pump_app.dart`. Padrão: Home e Vocabulário com `fixtures.dart` (dados de exemplo), capturas vazias (`fakeCaptures()`), player fake. Trocar: `home:`, `vocabulary:`, `captures:`, `playback:`, `auth:`.
- Erro de carregamento: `test/helpers/failing_stores.dart` (`FailingHomeStore`, `FailingVocabularyStore`; `failing = false` recupera).
- Montar widget via `test/helpers/pump_app.dart`: `pumpPage` (tela com tema + `AppScope` com stores carregados; `load: false` = carregando), `pumpComponent` (componente dentro de `Scaffold`). Tela de teste: 800x1600.
- Captura: `test/helpers/fake_capture_api.dart` (`FakeCaptureApi`: servidor de capturas em memória, `offline`, `rejections`, `process(id, texto)`, `calls`, `bodies`, `files`, página de 2). Banco: `AppDatabase(NativeDatabase.memory())`. Mídia: `MediaStorage(() async => pastaTemporaria)` em teste de store; em teste de tela, `FakeMediaStorage` (I/O real trava o `testWidgets`). `fakeCaptures()` em `test/helpers/fake_capture_store.dart` monta store + banco + API + mídia; `sampleCapture(id, ...)` cria captura; `FakeAudioPlayback` no lugar do player.
- Conta: `test/helpers/fake_auth.dart`. `FakeAuthApi` (resposta por rota `MÉTODO caminho`, padrão = caminho feliz; `errors`, `pending`, `signedIn` montam resposta; `error` simula sem rede; `last(rota)` = request enviado), `FakeTokenStorage`, `FakeSocialSignIn` (token ou `null` = cancelado), `fakeAuthStore()`. `pumpPage(auth: ...)`. Campo por rótulo: `textField('E-mail')`. iOS: `variant: TargetPlatformVariant.only(TargetPlatform.iOS)`.
- Unit test: model, service, lógica pura.
- Widget test: componente e tela com comportamento (toque, estado, navegação).
- Código novo ou alterado: teste junto. Bug corrigido: teste que reproduz o bug.
- Cobertura: `flutter test --coverage` → `coverage/lcov.info`. Toda lógica coberta; tela cobre fluxo principal.

## Dependências

Antes de adicionar pacote: checar pub.dev (likes, último publish), issues abertas (build/toolchain). Contar ao usuário antes de instalar. Plugin nativo ou pacote pouco mantido: perguntar.

Hoje: `google_sign_in` ^7.2, `sign_in_with_apple` ^8.2 (exige Flutter ≥3.44), `flutter_secure_storage` ^11.2, `drift` ^2.35.1, `drift_flutter` ^0.3.1, `path_provider` ^2.1.6, `audioplayers` ^6.8.1. Dev: `drift_dev` ^2.35.1, `build_runner`. iOS via Swift Package Manager (sem Podfile).

- Versão nova só com 2+ semanas de publicada (lockfile fixa). Vale pra transitiva também: `synchronized` ficou na 3.4.2 (3.5.0 tinha 10 dias). SQLite nativo vem do `sqlite3` (hooks de build, sem `sqlite3_flutter_libs`): `flutter test` usa o mesmo banco em memória.
- Mudou tabela do drift: `dart run build_runner build` → `dart format lib` → commitar `database.g.dart` junto (a esteira não gera código). Mudou coluna: subir `schemaVersion` + migração.

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
