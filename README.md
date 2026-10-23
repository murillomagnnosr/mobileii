# Carteira Digital

App Flutter da Carteira Digital. Cenas de **Login** e **Home** falando com a
API Carteira (`docs/api-referencia.pdf`, servidor mock do curso em `server/`).

## Como rodar

1. Suba a API em `http://localhost:8080`. Sem o servidor do curso, use o mock
   incluído no projeto (ou a configuração **Mock Server** no Android Studio):

   ```sh
   dart run tool/mock_server.dart
   ```

2. Rode o app no emulador Android (`dm_pixel`) ou no Chrome:

   ```sh
   flutter run
   ```

   No emulador Android o app usa `http://10.0.2.2:8080` automaticamente.

3. Credenciais de teste: `ana@carteira.dev` / `123456` e
   `bruno@carteira.dev` / `123456`.

## Fluxo

- Login com sucesso guarda o token (`shared_preferences`) e vai para a Home.
- Ao abrir o app com token guardado, vai direto para a Home.
- Erro de login mostra a mensagem na própria tela.
- Token inválido ou expirado (401) apaga o token e volta para o Login.

## Estrutura

- `lib/app/` — `StartupGate` (decide Login ou Home), `AppServices` (monta os
  repositórios uma vez), `SharedPrefsSessionStorage` e a chave de navegação.
- `lib/scenes/<cena>/` — `View`, `ViewModel`, `Coordinator` e `Factory`,
  com injeção de dependência pelo construtor.
- `packages/core/` — pacote `carteira_core`: modelos, `Result`/`AppError`,
  repositórios e cliente HTTP (`dio`). Rodar com `dart test` dentro da pasta.
- `packages/design_system/` — tokens, tema e componentes visuais.
- `tool/mock_server.dart` — mock mínimo da API para desenvolvimento.

## Testes

```sh
flutter test
```

Se o Windows bloquear o `flutter_tester.exe` (Smart App Control), rode os
testes no Chrome: `flutter test --platform chrome`.
