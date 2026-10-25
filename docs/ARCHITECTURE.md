# ARCHITECTURE — Tagarela

Mapa técnico. Detalhe fica no código. Aqui só decisão, regra e armadilha.

## Stack

- Flutter 3.44 / Dart 3.12. Só Android e iOS. Java 21 via `mise.toml` (Gradle 9 exige 17+).
- Estado: `ChangeNotifier` + `setState`. Navegação: `Navigator`. HTTP: `dart:io`. Sem pacote de estado, rota ou HTTP.
- Banco local: `drift` (SQLite). Conta: `google_sign_in`, `sign_in_with_apple`, `flutter_secure_storage`. Captura: `record`, `image_picker`, `permission_handler`, `audioplayers`. Extração: plugin local `on_device_extraction`.
- Mínimo: Android 8.0 (`minSdk 26`, exigido pelo Moonshine), iOS 15.0. iOS via Swift Package Manager, sem Podfile.
- `kotlin.incremental=false`: no Windows, projeto e pub cache em drives diferentes quebram o cache do Kotlin.

## Pastas

```
lib/
  app/            MaterialApp, AuthGate, HomeShell (abas + botão +), AppScope (stores)
  design_system/  tokens, tema, componentes. Ver DESIGN.md
  data/           models.dart, api_client.dart, store.dart, services/, stores/
                  + 1 arquivo por lib externa (database, token_storage, social_sign_in,
                    text_extractor, audio_playback, capture_device, model_storage)
  features/<f>/   <f>_page.dart + widgets/ (auth, capture, home, inbox, profile, vocabulary)
packages/on_device_extraction/  plugin: Kotlin (ML Kit + Moonshine), Swift (Vision + Moonshine)
test/             espelha lib/. Fakes e helpers em test/helpers/
```

## Onde colocar

- Widget de 2+ features ou genérico: `design_system/components/`. De uma feature: `features/<f>/widgets/`. De um arquivo só: classe privada.
- Model: `data/models.dart`, com `fromJson`. Conta sobre dado (total, filtro): no model, não no widget.
- Lib externa: só no arquivo dela em `data/`. Resto do app não importa a lib.
- Chamada de API: `data/services/` (1 por recurso, sem estado). Estado compartilhado: `data/stores/`.

## Dados e estado

- Fluxo: tela → store → service → `ApiClient` → API.
- `ApiClient`: único ponto de rede. Status ≥ 400 = `ApiException`. Corpo sempre com `Content-Length`: o `runserver` ignora corpo chunked.
- `Store<T>`: `data` + `error`. Os 2 nulos = carregando. Ação do store chama service e atualiza `data`.
- Recurso que a API não tem (palavra do dia, revisão): store sem service, fonte vazia. Card some sem dado.
- `AppScope`: stores, player e aparelho, injetados em `main.dart` (teste troca). `loadAll()` ao entrar.
- Tela: `ListenableBuilder` no store. Sem dado: `AsyncStatus`. Estado só da tela: `setState`.

### Conta

- allauth headless da API. Fluxos: `api/docs/ARCHITECTURE.md` (Auth).
- Refresh token no `flutter_secure_storage`. Access só na memória. 401 = renova uma vez e repete. Pedidos juntos dividem um refresh.
- Refresh recusado no uso: volta pro login com "Sua sessão expirou". Sem rede ao abrir: entra com o token salvo.
- Google: client ID web vem da API (`GET config`). iOS ainda falta `GOOGLE_IOS_CLIENT_ID` + URL scheme. Apple: só iOS.

### Vocabulário

- Só online, sem banco local. Ler, criar grupo e mover chamam a API na hora.
- Termo nasce na API ao confirmar a captura. `CaptureStore(onConfirmed:)` recarrega o vocabulário.
- Desfazer mover = mover de volta pro grupo de origem.
- Ícone do grupo: enum `GroupIcon`. Nome = id na API. Ordem do enum = ordem no painel.

### Captura (offline first)

- Verdade: banco local. API = sincronização. Cada linha guarda o e-mail do dono.
- Id UUID gerado no app. Foto e áudio ficam no celular. Só o texto sobe.
- Pendências: `extract` (só local), `create`, `update`, `confirm`, `discard`. Ação grava local, marca pendência e tenta enviar. Sem rede: fica pendente, sem erro.
- Sync só por ação da pessoa (decisão do produto). Sem timer, sem segundo plano. `sync()` envia em ordem e puxa `updated_since`. Cursor = maior `updated_at` do pull, não do envio.
- Merge: servidor manda, menos o que está pendente no celular.
- Mídia apagada 30 dias depois de analisada ou descartada.
- Extração: fila no `CaptureStore`, uma por vez. Áudio sem modelo espera o download e volta pra fila.
- Posição do termo: API conta code points, Dart conta UTF-16. `TermSelection` converte na entrada e na saída.
- Limites: texto 500 ao digitar, 2000 ao editar. Termo até 100. Até 50 termos.

## Extração no aparelho

- Plugin `on_device_extraction`: `recognizeText`, `transcribe`, `release`. Nada na thread principal.
- Foto: ML Kit v2 unbundled no Android (modelo vem do Play Services), Vision no iOS.
- Áudio: Moonshine Tiny Streaming inglês, 45 MB. Baixa sozinho no `loadAll`, de URL fixa do Hugging Face (CDN deu 404). SHA-256 por arquivo, retoma, tenta de novo de 30 s até 10 min. Trocar modelo = nova constante `SpeechModel`.
- Android: deps da lib Moonshine excluídas + `consumer-rules.pro` (JNI lê classe por nome, R8 do release). APK universal passa de 100 MB; App Bundle entrega só a ABI do aparelho.
- iOS: `moonshine-swift` versão exata, exige Xcode 16.3+.

## API

- URL: `--dart-define=API_URL=...`. Padrão `http://10.0.2.2:8000` (emulador). Celular físico: IP do PC.
- http só no debug. Release: só https.
- Contratos: `api/docs/ARCHITECTURE.md` (Endpoints).

## Layout

- Toda tela = `SheetPage`. Estado de tela (vazio, erro): `centerLast: true` com `StateMessage`/`AsyncStatus` por último.
- `HomeShell`: `IndexedStack` das abas, `resizeToAvoidBottomInset: false` (cada aba cuida do teclado).
- Grupo abre em tela cheia, sem tab bar.

## Convenções

- Import `package:tagarela/...`. Feature importa DS só via `design_system.dart`. Aspas simples.
- Texto da UI em pt-BR, direto no widget. Rótulo de enum no enum.
- Um widget público por arquivo, `snake_case.dart`.

## Testes

- Só `flutter_test`. Fake manual, sem pacote de mock.
- Montar: `pumpPage` / `pumpComponent` (`test/helpers/pump_app.dart`). Fakes de API, banco, mídia, extrator, player, aparelho e conta em `test/helpers/`.
- I/O real trava `testWidgets`: em tela, `FakeMediaStorage`.
- Tela que faz `pop`: abrir de outra tela, nunca como `home`. Timer (gravação, toast): `pump(Duration)`, não `pumpAndSettle`.
- Unit: model, service, lógica. Widget: componente e tela com comportamento. Bug corrigido: teste que reproduz.

## Comandos

Sempre a versão de saída curta:

- `dart format lib test packages`
- `flutter analyze --no-pub`
- `flutter test --no-pub -r failures-only`
- Mudou tabela do drift: `dart run build_runner build` e commitar `database.g.dart`. Mudou coluna: subir `schemaVersion` + migração.

## Dependências

- Antes de pacote novo: checar pub.dev e issues, contar ao usuário. Nativo ou pouco mantido: perguntar.
- Versão nova só com 2+ semanas de publicada, transitiva também.
- `permission_handler` preso na 12: a 13 exige compileSdk 37.
- Nativas do plugin: versão fixa no `build.gradle.kts` e no `Package.swift`.

## Git e CI

- Branch da `develop`: `feat/`, `fix/`, `docs/`, `ci/`, `chore/`. PR pra `develop`, squash. `main` = produção.
- Esteira (`ci.yml`): formato, análise, testes com cobertura, OSV-Scanner, build APK. Build iOS só na `main`.
- `FLUTTER_VERSION` do workflow = Flutter local. Subiu um, subir o outro.
