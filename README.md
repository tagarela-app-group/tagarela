# Tagarela

App mobile (Flutter) para aprender inglês, espanhol e português com termos do dia a dia.

Comece por [CLAUDE.md](CLAUDE.md).

Dois ambientes, um flavor para cada, com o seu arquivo em `env/`:

| | dsv | prd |
|---|---|---|
| Env | `env/dsv.json` | `env/prd.json` |
| Pacote | `com.tagarela.dsv` | `com.tagarela.app` |
| Nome no aparelho | Tagarela DSV | Tagarela |

## dsv

```sh
flutter pub get
flutter run   # API do repo api/ no ar (docker compose up); ou --dart-define=API_URL=https://...
```

`flutter run` usa o dsv sem precisar de argumento. O dsv não tem build de release.

No Android, o build de debug faz `adb reverse tcp:8000 tcp:8000` em todo aparelho conectado (emulador ou físico, USB ou Wi-Fi), então `localhost:8000` no app chega na API do PC.

## prd

```sh
flutter build appbundle --flavor prd
flutter build ipa --flavor prd
```

Antes do primeiro build para a loja:

1. Troque o `API_URL` em `env/prd.json` pelo domínio real. O deploy da API está em `../api/docs/deploy.md`.
2. Android: crie a chave de release e copie `android/key.properties.example` para `android/key.properties`, que fica fora do git, assim como a chave. Sem esse arquivo, o build usa a chave de debug, que a loja recusa.
3. Google: crie o client Android do pacote `com.tagarela.app` com o SHA-1 da chave de release. No iOS, crie o client iOS e preencha `GOOGLE_IOS_CLIENT_ID` no env.
4. Apple: habilite o Sign in with Apple no App ID `com.tagarela.app`.
