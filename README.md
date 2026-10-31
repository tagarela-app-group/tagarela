# Tagarela

App mobile (Flutter) para aprender inglês, espanhol e português com termos do dia a dia.

Comece por [CLAUDE.md](CLAUDE.md).

```sh
flutter pub get
flutter run   # API do repo api/ no ar (docker compose up); ou --dart-define=API_URL=https://...
```

No Android, o build de debug faz `adb reverse tcp:8000 tcp:8000` em todo aparelho conectado (emulador ou físico, USB ou Wi-Fi), então `localhost:8000` no app chega na API do PC.
