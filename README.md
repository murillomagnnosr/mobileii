# Carteira Digital

App Flutter da Carteira Digital. Cenas de **Login**, **Home**, **Extrato**,
**Detalhe**, **Novo/Editar lançamento** e **Perfil** falando com a API Carteira.

## Documentação

- [`docs/api.md`](docs/api.md) — todas as rotas da API, com requests,
  responses e erros.
- [`docs/tema-e-design-system.md`](docs/tema-e-design-system.md) — tema
  (tokens, claro/escuro), componentes, sample app e protótipos das telas.
- [`docs/padroes-de-projeto.md`](docs/padroes-de-projeto.md) — onde cada
  padrão de projeto aparece no código.

## Como rodar

1. Suba a API em `http://localhost:8080`. Sem o servidor do curso, use o mock
   incluído no projeto (ou a configuração **Mock Server** no Android Studio):

   ```sh
   dart run tool/mock_server.dart
   ```

   Opções do mock (detalhes em [`docs/api.md`](docs/api.md#mock-local)):

   | Opção / variável                   | Padrão    | Efeito                                         |
   | ---------------------------------- | --------- | ---------------------------------------------- |
   | `--port <porta>` (ou `-p`)         | 8080      | outra porta; `0` escolhe uma livre             |
   | `PORT`                             | 8080      | porta, quando `--port` não é informado         |
   | `LATENCY_MIN_MS` / `LATENCY_MAX_MS`| 300 / 800 | faixa de latência por requisição, em ms        |

   ```sh
   # Porta 9090 e sem latência (bash; no PowerShell use $env:LATENCY_MAX_MS = "0")
   LATENCY_MAX_MS=0 dart run tool/mock_server.dart --port 9090
   ```

   O app sempre fala com a porta 8080 (`lib/app/api_config.dart`); outra
   porta serve para testes ou para rodar um segundo mock ao lado.
   Em qualquer requisição, os cabeçalhos `X-Delay-Ms` e `X-Fail`
   (`500`, `expired`, `timeout`) simulam lentidão e erros.

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
- Home: avatar abre o Perfil, "Ver todos" abre o Extrato, `+` cria um
  lançamento e tocar num lançamento abre o Detalhe. Ao voltar, a Home recarrega.
- Extrato: busca por descrição, filtro por tipo e paginação ("Carregar mais").
- Detalhe: editar e excluir (com confirmação).
- Perfil: editar nome, escolher tema (claro, escuro, sistema) e sair.

## Estrutura

- `lib/app/` — `StartupGate` (decide Login ou Home), `AppServices` (monta os
  repositórios uma vez), `SharedPrefsSessionStorage` e a chave de navegação.
- `lib/scenes/<cena>/` — `View`, `ViewModel`, `Coordinator` e `Factory`,
  com injeção de dependência pelo construtor.
- `packages/core/` — pacote `carteira_core`: modelos, `Result`/`AppError`,
  repositórios e cliente HTTP (`dio`). Rodar com `dart test` dentro da pasta.
- `packages/design_system/` — tokens, tema e componentes visuais;
  `example/` é a galeria (sample app) com os protótipos das telas.
- `tool/mock_server.dart` — mock com todas as rotas da API para desenvolvimento;
  a lógica fica em `tool/mock_server/` (`mock_server.dart` com
  `startMockServer`, `seed.dart` com os dados iniciais e `cli.dart` com as
  opções de linha de comando), importável pelos testes.

## Testes

```sh
flutter test
```

`test/tool/` testa o mock: o contrato rota a rota contra a referência da API
(`mock_server_contract_test.dart`), a camada de dados do `carteira_core`
contra o mock (`mock_server_e2e_test.dart`) e a linha de comando
(`mock_server_cli_test.dart`, que roda `dart tool/mock_server.dart` como
processo). Todos usam porta livre, nunca a 8080, e só rodam na VM (usam
`dart:io`).

Se o Windows bloquear o `flutter_tester.exe` (Smart App Control), rode os
testes no Chrome: `flutter test --platform chrome` (exceto `test/tool/`).
