# ARCHITECTURE — Tagarela

## Stack

- Flutter 3.44 / Dart 3.12. Só Android e iOS.
- HTTP via `dart:io`. Estado via `ChangeNotifier` + `setState`. Navegação com `Navigator`.
- Dependências: conta (`google_sign_in`, `sign_in_with_apple`, `flutter_secure_storage`), captura offline (`drift` + `drift_flutter`: SQLite local; `path_provider`: pasta do app) `audioplayers` (ouvir a gravação), captura no aparelho (`record`: gravar; `image_picker`: câmera e galeria; `permission_handler`: microfone, câmera e abrir as configurações) e extração no aparelho (plugin local `on_device_extraction`; `crypto`: hash do modelo baixado). Fora isso, zero pacote. Ver Dependências.
- Fontes embutidas em `assets/fonts/` (sem pacote, funciona offline).
- Mínimo: Android 8.0 (`minSdk = 26`, exigido pelo Moonshine), iOS 15.0 (`moonshine-swift`).
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
    media_storage.dart   foto/áudio na pasta de documentos do app (path_provider)
    model_storage.dart   modelo de áudio na pasta de suporte do app (path_provider) + download (dart:io, SHA-256)
    speech_model.dart    registro do modelo de áudio: id, arquitetura, URL fixa, arquivos (tamanho + SHA-256)
    text_extractor.dart  único ponto que conhece o plugin on_device_extraction: foto/áudio → texto, erros
    audio_playback.dart  único ponto que conhece audioplayers: um player pro app todo (toca um áudio por vez)
    capture_device.dart  único ponto que conhece record, image_picker e permission_handler: gravar, foto, permissão
    services/            1 por recurso da API (sem estado)
    stores/              estado compartilhado (1 por recurso). speech_model_store.dart: estado do modelo de áudio (Perfil)
  features/<feature>/    <feature>_page.dart + widgets/ (só da feature)
  features/auth/         login, cadastro, código, esqueci senha, nova senha + auth_form.dart (mixin de envio)
  features/capture/      painéis de captura (texto, foto, áudio) abertos pelo + do HomeShell + aviso "Salvo no Inbox"
  features/inbox/        Inbox + tela Escolher termos (pick_terms_page.dart) + term_selection.dart (marcar, editar texto, posição dos termos)
  features/profile/      Perfil + widgets/speech_model_card.dart (Transcrição offline)
packages/
  on_device_extraction/  plugin local (pub workspace): MethodChannel → Kotlin (ML Kit + Moonshine) e Swift (Vision + Moonshine). Ver Extração no aparelho
assets/
  fonts/                 Bricolage Grotesque + DM Sans (TTF estático) + OFL
  images/                google.png (botão de login)
test/                    espelha lib/. Ver Testes
docs/                    PRODUCT, ARCHITECTURE, DESIGN
build.yaml               opção do drift_dev (data como texto ISO, mantém fuso e microssegundo)
```

## Onde colocar

- Widget usado em 2+ features ou genérico: `design_system/components/`.
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

- `ApiClient`: único ponto de rede da API. JSON, timeout 10 s. Download do modelo de áudio: `ModelStorage`. Status ≥ 400 vira `ApiException`.
- Service: chama endpoint e converte JSON em model. Sem estado. Trocar de API = mexer só em service (e `fromJson`).
- Store: `Store<T>` (`ChangeNotifier`) guarda `data` e `error` de um recurso. `data` e `error` nulos = carregando. Ação (ex.: `CaptureStore.confirm`) grava, chama service e atualiza `data`.
- Recurso que a API ainda não tem (Home: estatística e palavra do dia; Vocabulário: grupos e termos): store sem service, fonte local vazia (`HomeStore.empty`, `VocabularyStore()`). Teste passa dados no construtor. Tela some com o card sem dado (palavra do dia, revisão) e mostra estado vazio (Vocabulário). API ganhou o recurso: store volta a chamar service.
- `AppScope`: guarda os stores, o `AudioPlayback` e o `CaptureDevice`; tela pega via `AppScope.of(context)`. `loadAll()` ao entrar: limpa mídia vencida, carrega tudo (estado do modelo de áudio junto) e retoma extração pendente (`extractPending`). `AuthStore`, `CaptureStore`, `SpeechModelStore`, `AudioPlayback` e `CaptureDevice` vêm prontos de fora (`main.dart`), pra teste trocar API, banco, mídia, extrator, modelo, player e aparelho.
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
- Criar: id UUID v4 gerado no app (`Random.secure`). Texto nasce `ready`. Foto/áudio: arquivo copiado pra `captures/<photo|audio>/<id>.<ext>` na pasta de documentos do app; nasce `processing` com `extract` + `create` pendentes (texto sai no aparelho, ver Extração no aparelho). Com `EXTRACTION=server`: nasce `waiting_file` com `create` + `file` (fluxo antigo, texto no servidor).
- Pendência (`Capture.pending`): `extract` (só do app: falta ler o texto no aparelho), `create`, `file`, `update`, `confirm`, `discard`. Com `extract` pendente, nada sobe pra API. Ação grava local + marca pendência + tenta enviar na hora (sem rede: fica pendente, sem erro).
- Sincronizar só por ação da pessoa (decisão do produto, por enquanto): criar, editar, confirmar, descartar, `processNow` ("Processar agora") e `sync()` (puxar a lista). Sem timer, sem segundo plano. No modo servidor, `processing` → `ready` só aparece puxando a lista.
- `sync()`: envia pendências em ordem (`create` → `file` → `update` → `confirm`; `discard` sozinho) e puxa mudanças (`GET captures?updated_since=<cursor>`, paginado por `cursor`). Cursor por dono em `capture_cursors` = maior `updated_at` vindo do pull (não do envio, pra não pular mudança de outro aparelho). Sem rede: lança, pendência fica. API recusa (4xx menos 401): larga só aquela etapa e segue.
- Merge (`Capture.merge`): servidor manda, menos o que está pendente no celular (texto/termos em `update`, status em `confirm`, descarte em `discard`). Arquivo local sempre fica.
- Descartar nunca enviada: só some do celular, sem chamar a API.
- Mídia: apagada só 30 dias depois de analisada ou descartada (`Capture.mediaRetention`, `cleanMedia`). Pendente, pronta ou com erro: nunca. Texto fica sempre.
- Extração (`extract`): fila no `CaptureStore`, uma captura por vez, fora da tela (o painel fecha na hora). Leu: `ready` com `text` = `originalText` (espaços e linhas viram um espaço, corta na última palavra que cabe em 2000), `processedAt`, sai o `extract` e tenta o `create` com o texto (sem rede: fica `create` pendente, captura já pronta e confirmável offline). Falhou: `failed` + `error` (`model_missing`: modelo de áudio não baixado; `no_text`: nada lido; `extraction_failed`: plugin quebrou ou arquivo sumiu), `extract` fica. `processNow` em captura com `extract`: volta pra `processing` e entra na fila de novo. Fila vazia: `TextExtractor.release()` solta modelo e recognizer da memória. Descartar antes de subir: só some do celular.
- Modo de extração: `--dart-define=EXTRACTION=server` usa o fluxo do servidor (OCR/Whisper no worker), pra comparar. Padrão `device`.
- Telas: `+` do `HomeShell` abre `AppSheet` (texto, foto ou áudio). Salvar = `createText`/`createMedia`, que devolvem a captura depois da tentativa de envio (`pending` vazio = enviou). Painel fecha com a captura; `HomeShell` mostra o aviso (`showCaptureSaved`).
- Texto: até 500 caracteres no app (API aceita 2000).
- Foto: `image_picker`, lado maior até 2000 px, JPEG qualidade 85. Câmera pede permissão; galeria não precisa (seletor do sistema).
- Áudio: `record`, AAC-LC em m4a, mono, 16 kHz, 48 kbps. Abre já gravando; para no toque ou sozinho em 60 s (`CaptureDevice.maxRecording`). Tempo pela contagem do timer (`Timer.tick`).
- Arquivo temporário (foto escolhida, gravação): apagado ao fechar o painel, salvando ou não (`CaptureDevice.discard`). Salvar copia antes pra pasta do app. Fechar gravando cancela a gravação.
- Escolher termos (`PickTermsPage`, aberta pelo card pronto): estado local até confirmar. Confirmar = `confirm(capture, text:, terms:)`: uma mudança com `update` + `confirm` pendentes. Voltar descarta o que foi marcado. Lixeira = `discard`.
- Termo (`TermSelection`): palavra = trecho sem espaço, sem a pontuação das pontas (letra, número e acento ficam). Toque = palavra; arrasto (começa onde o dedo desceu) = da primeira à última palavra. Mesmo trecho de novo = desmarca. Ordem: início, depois o maior.
- Posição do termo: a API conta em code points (Python), o Dart em UTF-16. `TermSelection` converte na entrada (`TermSelection.of`) e na saída (`toTerms`); emoji não desalinha.
- Editar texto: compara o antigo com o novo (prefixo e sufixo comuns). Termo antes do trecho mudado fica; depois, desloca; encostou na mudança ou a palavra mudou: cai. Texto vazio volta ao anterior.
- Limites da API no app: texto até 2000 ao editar (transcrição de 60 s passa de 500), termo até 100 caracteres, até 50 termos. Passou: aviso, não marca.
- Permissão negada (microfone, câmera): painel mostra aviso com "Abrir configurações" (`openAppSettings`) e fecha. Android: `RECORD_AUDIO` e `CAMERA` no `AndroidManifest.xml`. iOS: `NSMicrophoneUsageDescription`, `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` no `Info.plist`; com Swift Package Manager o `permission_handler` liga cada permissão pela chave presente no `Info.plist` (sem Podfile).

## Extração no aparelho

- Plugin local `packages/on_device_extraction` (pub workspace, `path`). Canal `on_device_extraction`: `recognizeText(path)`, `transcribe(path, modelPath, arch)`, `release()`. Erro nativo = `PlatformException` `extraction_failed`.
- Thread: Android num `Executor` de uma thread, resposta na main; iOS numa `DispatchQueue` serial `.userInitiated`. Nada roda na thread principal.
- Foto, Android: ML Kit Text Recognition v2 latino, unbundled (`play-services-mlkit-text-recognition`, +~260 KB). Modelo vem do Google Play Services; meta-data `com.google.mlkit.vision.DEPENDENCIES=ocr` no manifest do plugin pede o download na instalação. Sem Play Services ou modelo ainda baixando: `extraction_failed` (Processar agora tenta de novo). `InputImage.fromFilePath` respeita a rotação do EXIF.
- Foto, iOS: Apple Vision `VNRecognizeTextRequest` (`.accurate`, `en-US`, correção de idioma). Orientação lida do EXIF. Zero bundle, zero download.
- Áudio (os dois): Moonshine Tiny Streaming inglês (34M parâmetros, MIT), `transcribeWithoutStreaming` depois de parar a gravação. Android decodifica o m4a com `MediaExtractor` + `MediaCodec`; iOS com `AVAudioFile`. Vira PCM float mono na taxa do arquivo (16 kHz); o Moonshine reamostra se precisar. Linhas do transcript unidas por espaço.
- Memória: modelo carregado na 1ª transcrição e reaproveitado na fila; `release()` (fila vazia) solta. Trocou o caminho ou a arquitetura: recarrega.
- Modelo: `SpeechModel.current` = `tiny-streaming-en` quantizado (`quantized_26_08_21`), 8 arquivos, 45 MB. Fonte: mirror oficial `huggingface.co/moonshine-ai/moonshine-voice-assets`, URL fixa no commit (arquivo nunca muda). CDN `download.moonshine.ai` deu 404. `decoder_kv_with_attention.ort` (word timestamps) fica de fora.
- Download (`ModelStorage`, botão no Perfil): `<app support>/models/<id>/`. Cada arquivo baixa como `.part`, confere SHA-256 e renomeia; arquivo já baixado com o tamanho certo é pulado (retoma). Fim: marca `.complete` e apaga pasta de outro modelo. Conexão 15 s, sem dado 30 s = erro. `installed()` = tem `.complete`.
- Trocar modelo: nova constante `SpeechModel` (Small Streaming 123M, Medium Streaming 245M ~255 MB; `MoonshineArch`) e `SpeechModel.current` aponta pra ela. Baixar o novo apaga o antigo.
- Android (`android/build.gradle.kts` do plugin): `ai.moonshine:moonshine-voice` sem `material`, `okhttp` e `work-runtime` (só o downloader e TTS da lib usam). `consumer-rules.pro`: `-keep` nas classes que o JNI do Moonshine lê por nome + `-dontwarn` das excluídas (R8 do release). Manifest do plugin remove a `MicrophonePermissionActivity` da lib. Tamanho: `libmoonshine` + `libonnxruntime` ≈ 17,5 MB por ABI no aparelho (arm64), ~8 MB comprimido. APK universal (3 ABIs) passa de 100 MB; App Bundle entrega só a ABI do aparelho.
- iOS (`ios/on_device_extraction/Package.swift`): `moonshine-swift` 0.1.5 exato (xcframework estático). Pacote dele usa swift-tools 6.1: Xcode 16.3+.

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
- Antes de entregar: `dart format lib test packages`, `flutter analyze` sem issues, `flutter test` verde.

## Testes

- Pasta `test/` espelha `lib/`: `lib/x/y.dart` → `test/x/y_test.dart`.
- Só `flutter_test` (vem no SDK). Sem pacote de mock: fake manual.
- Escopo de teste: `testScope(child: ...)` / `pumpPage(...)` em `test/helpers/pump_app.dart`. Padrão: Home e Vocabulário com `fixtures.dart` (dados de exemplo), capturas vazias (`fakeCaptures()`), player fake, aparelho fake. Trocar: `home:`, `vocabulary:`, `captures:`, `playback:`, `device:`, `auth:`.
- Erro de carregamento: `test/helpers/failing_stores.dart` (`FailingHomeStore`, `FailingVocabularyStore`; `failing = false` recupera).
- Montar widget via `test/helpers/pump_app.dart`: `pumpPage` (tela com tema + `AppScope` com stores carregados; `load: false` = carregando), `pumpComponent` (componente dentro de `Scaffold`). Tela de teste: 800x1600.
- Captura: `test/helpers/fake_capture_api.dart` (`FakeCaptureApi`: servidor de capturas em memória, `offline`, `rejections`, `process(id, texto)`, `calls`, `bodies`, `files`, página de 2). Banco: `AppDatabase(NativeDatabase.memory())`. Mídia: `MediaStorage(() async => pastaTemporaria)` em teste de store; em teste de tela, `FakeMediaStorage` (I/O real trava o `testWidgets`). `fakeCaptures()` em `test/helpers/fake_capture_store.dart` monta store + banco + API + mídia; `sampleCapture(id, ...)` cria captura; `FakeAudioPlayback` no lugar do player; `FakeCaptureDevice` no lugar do aparelho (`camera`/`microphone` = permissão, `nextPhoto` (`null` = desistiu), `recording`, `recordings`, `cancelled`, `discarded`, `settingsOpened`, `origins`). Tela que volta (`Navigator.pop`): abrir por um botão numa tela anterior, nunca como `home`. Arrasto: `tester.dragFrom` (começa na palavra onde o dedo desceu). Painel: `tester.openSheet(painel, ...)` em `test/helpers/open_sheet.dart` devolve a lista de resultados ao fechar. Gravação: `pump(Duration)`, não `pumpAndSettle` (timer de 200 ms).
- Conta: `test/helpers/fake_auth.dart`. `FakeAuthApi` (resposta por rota `MÉTODO caminho`, padrão = caminho feliz; `errors`, `pending`, `signedIn` montam resposta; `error` simula sem rede; `last(rota)` = request enviado), `FakeTokenStorage`, `FakeSocialSignIn` (token ou `null` = cancelado), `fakeAuthStore()`. `pumpPage(auth: ...)`. Campo por rótulo: `textField('E-mail')`. iOS: `variant: TargetPlatformVariant.only(TargetPlatform.iOS)`.
- Extração: `test/helpers/fake_extraction.dart`. `FakeTextExtractor` (`results` por fonte: texto ou `ExtractionError`; `extracted`, `released`, `hold` segura a fila), `FakeModelStorage` (`path` = instalado, `offline`, `steps` de progresso, `hold`, `downloads`, `removed`), `fakeSpeechModel(ready:)`. `fakeCaptures(extractor: ...)` liga o modo aparelho (sem extrator = modo servidor). Esperar a fila: `await store.extractions`. `pumpPage(speech: ...)`. Plugin: `setMockMethodCallHandler` no canal `on_device_extraction`. Download: `HttpServer` local em `ModelStorage`.
- Unit test: model, service, lógica pura.
- Widget test: componente e tela com comportamento (toque, estado, navegação).
- Código novo ou alterado: teste junto. Bug corrigido: teste que reproduz o bug.
- Cobertura: `flutter test --coverage` → `coverage/lcov.info`. Toda lógica coberta; tela cobre fluxo principal.

## Dependências

Antes de adicionar pacote: checar pub.dev (likes, último publish), issues abertas (build/toolchain). Contar ao usuário antes de instalar. Plugin nativo ou pacote pouco mantido: perguntar.

Hoje: `google_sign_in` ^7.2, `sign_in_with_apple` ^8.2 (exige Flutter ≥3.44), `flutter_secure_storage` ^11.2, `drift` ^2.35.1, `drift_flutter` ^0.3.1, `path_provider` ^2.1.6, `audioplayers` ^6.8.1, `record` ^7.1.2, `image_picker` ^1.2.4, `permission_handler` ^12.0.3, `crypto` ^3.0.7, `on_device_extraction` (local). Dev: `drift_dev` ^2.35.1, `build_runner`. iOS via Swift Package Manager (sem Podfile).

Nativas do plugin local: Android `com.google.android.gms:play-services-mlkit-text-recognition` 19.0.1 e `ai.moonshine:moonshine-voice` 0.1.5 (Maven Central); iOS `moonshine-swift` 0.1.5 (SPM, `exact`). Versão fixa no `build.gradle.kts` e no `Package.swift`: subir lá.

- Versão nova só com 2+ semanas de publicada (lockfile fixa). Vale pra transitiva também: `synchronized` ficou na 3.4.2 (3.5.0 tinha 10 dias); `permission_handler_apple` na 9.6.2 (9.6.3 e 9.6.4 tinham 0 e 2 dias); `permission_handler` na 12 porque a 13 traz o `permission_handler_android` 14, que exige compileSdk 37 (Flutter e AGP 9.0.1 usam 36). SQLite nativo vem do `sqlite3` (hooks de build, sem `sqlite3_flutter_libs`): `flutter test` usa o mesmo banco em memória.
- Mudou tabela do drift: `dart run build_runner build` → `dart format lib` → commitar `database.g.dart` junto (a esteira não gera código). Mudou coluna: subir `schemaVersion` + migração.

## Git e CI

- Branches: `main` = produção. `develop` = integração. Cada mudança = branch nova a partir da `develop`: `feat/`, `fix/`, `docs/`, `ci/`, `chore/` + nome curto.
- Fluxo: branch → commit → push → PR pra `develop`. Esteira verde → squash merge, branch apagada. Release: PR `develop` → `main` (merge commit), aprovado pelo usuário.
- Esteira: `.github/workflows/ci.yml`. Roda em todo PR e push na `develop`/`main`. Push novo no mesmo PR cancela a rodada anterior.
  - Formato, análise e testes: `flutter pub get --enforce-lockfile`, `dart format --set-exit-if-changed lib test packages`, `flutter analyze`, `flutter test --coverage`. Cobertura no resumo da rodada + artefato `cobertura`.
  - Dependências vulneráveis: OSV-Scanner em todo lockfile do repo (`pubspec.lock`, `Podfile.lock`...). Versão fixa: o Google avisa que muda até em patch. Vulnerabilidade conhecida reprova o PR.
  - Build Android: `flutter build apk --release` (chave de debug). APK no artefato `apk`, 7 dias.
  - Build iOS: `flutter build ios --release --no-codesign`. Só PR/push na `main` (macOS lento).
- Flutter da esteira = `FLUTTER_VERSION` no workflow. Subiu o Flutter local: subir lá junto.
- GitHub (config do repo): Dependabot alerts + security updates (PR de correção sozinho), secret scanning + push protection (bloqueia push com segredo).
- Antes do push, rodar local: `dart format lib test packages`, `flutter analyze`, `flutter test`.
