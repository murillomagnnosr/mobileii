# API Carteira — requests e responses

Documentação de todas as rotas consumidas pelo app Carteira Digital, com o
formato exato de cada requisição e resposta. Baseada na referência do curso
(`api-referencia.pdf`, servidor `server/` versão 0.1.0) e implementada também
pelo mock local `tool/mock_server.dart`.

No app, quem fala com a API é o pacote `carteira_core`:
`ApiClient` (transporte + mapeamento de erros) e os repositórios remotos
(`RemoteAuthRepository`, `RemoteUserRepository`, `RemoteTransactionRepository`).
A coluna **No app** das tabelas indica o método que chama cada rota.

## Sumário

| Verbo  | Rota                  | Auth | Sucesso | No app                                  |
| ------ | --------------------- | ---- | ------- | --------------------------------------- |
| GET    | `/health`             | não  | 200     | —                                       |
| POST   | `/auth/login`         | não  | 200     | `AuthRepository.login`                  |
| POST   | `/auth/logout`        | sim  | 204     | `AuthRepository.logout`                 |
| GET    | `/me`                 | sim  | 200     | `UserRepository.getProfile`             |
| PUT    | `/me`                 | sim  | 200     | `UserRepository.updateProfile`          |
| GET    | `/transactions`       | sim  | 200     | `TransactionRepository.list`            |
| GET    | `/transactions/:id`   | sim  | 200     | `TransactionRepository.getById`         |
| POST   | `/transactions`       | sim  | 201     | `TransactionRepository.create`          |
| PUT    | `/transactions/:id`   | sim  | 200     | `TransactionRepository.update`          |
| DELETE | `/transactions/:id`   | sim  | 204     | `TransactionRepository.delete`          |
| GET    | `/summary`            | sim  | 200     | `TransactionRepository.summary`         |
| POST   | `/reset`              | sim  | 204     | — (utilitário de desenvolvimento)       |

## Regras gerais

- **Base URL:** `http://localhost:8080`. No emulador Android,
  `http://10.0.2.2:8080` (`lib/app/api_config.dart` escolhe sozinho).
- **Formato:** corpo e resposta em JSON, `Content-Type: application/json; charset=utf-8`.
- **Autenticação:** rotas protegidas exigem `Authorization: Bearer <token>`,
  com o token devolvido pelo login. O `ApiClient` coloca o cabeçalho em toda
  requisição depois do login.
- **Dados por sessão:** cada login recebe uma cópia própria dos dados de
  exemplo. O que uma sessão altera, outra não vê.
- **Datas:** ISO 8601 em UTC (`2026-09-06T14:32:00Z`).
- **Valores:** `number` com duas casas, sempre positivo. O `type` diz se o
  dinheiro entra ou sai.
- **Campos opcionais:** vêm sempre, com `null` quando vazios.
- **Latência:** de 300 a 800 ms.
- **CORS:** qualquer origem; `OPTIONS` responde 204.
- **Credenciais de teste:** `ana@carteira.dev` / `123456` e
  `bruno@carteira.dev` / `123456`.

## Modelos

### `user`

```json
{
  "id": "usr_01",
  "name": "Ana Ribeiro",
  "email": "ana@carteira.dev",
  "avatarUrl": null,
  "createdAt": "2024-03-11T09:00:00Z"
}
```

Modelo Dart: `User` (`packages/core/lib/src/models/user.dart`).

### `transaction`

```json
{
  "id": "tx_0042",
  "type": "expense",
  "amount": 89.9,
  "description": "Mercado",
  "category": "Alimentação",
  "date": "2026-09-06T14:32:00Z",
  "note": null,
  "account": "Nubank",
  "toAccount": null
}
```

| Campo         | Tipo     | Regra                                              |
| ------------- | -------- | -------------------------------------------------- |
| `id`          | string   | gerado pelo servidor                               |
| `type`        | string   | `income`, `expense` ou `transfer`                  |
| `amount`      | number   | maior que zero; arredondado a duas casas           |
| `description` | string   | não vazia                                          |
| `category`    | string?  | texto vazio vira `null`                            |
| `date`        | string   | data ISO 8601 válida; devolvida em UTC             |
| `note`        | string?  | texto vazio vira `null`                            |
| `account`     | string   | não vazia                                          |
| `toAccount`   | string?  | obrigatório se `type = transfer`; senão, `null`    |

Uma transferência não entra no saldo. Modelo Dart: a classe selada
`Transaction`, com as subclasses `Income`, `Expense` e `Transfer`
(`packages/core/lib/src/models/transaction.dart`); `Transaction.fromJson`
escolhe a subclasse pelo `type`.

### `summary`

```json
{ "month": "2026-09", "income": 9526.55, "expense": 5330.04, "balance": 4196.51 }
```

Modelo Dart: `Summary`. O `balance` é recalculado no app (`income - expense`).

### `page`

```json
{ "items": [ /* transaction */ ], "page": 1, "pageSize": 20, "total": 42 }
```

Modelo Dart: `Page<T>`, com `hasMore` (`page * pageSize < total`).

## Erros

Toda falha tem o mesmo formato. Em 422 o objeto ganha `fields`, com uma
mensagem por campo inválido:

```json
{
  "error": {
    "code": "validation",
    "message": "Invalid transaction",
    "fields": { "amount": "must be greater than zero" }
  }
}
```

| Status | `code`                | Quando                                  | `AppError` no app                         |
| ------ | --------------------- | --------------------------------------- | ----------------------------------------- |
| 400    | `bad_request`         | corpo não é JSON válido                 | `UnknownError`                            |
| 401    | `invalid_credentials` | e-mail ou senha errados no login        | `UnauthorizedError(invalidCredentials)`   |
| 401    | `unauthorized`        | token ausente, desconhecido ou encerrado| `UnauthorizedError`                       |
| 401    | `token_expired`       | só com `X-Fail: expired`                | `UnauthorizedError(expired)`              |
| 404    | `not_found`           | transação ou rota inexistente           | `NotFoundError`                           |
| 422    | `validation`          | campos ou parâmetros inválidos          | `ValidationError(fields)`                 |
| 500    | `internal`            | erro inesperado ou `X-Fail: 500`        | `ServerError(500)`                        |
| —      | —                     | sem conexão / tempo esgotado            | `NetworkError` / `TimeoutError`           |

O mapeamento fica em `ApiClient.mapError`. Os repositórios nunca lançam
exceção: devolvem `Result<T>` (`Ok` ou `Failure(AppError)`), e toda cena que
recebe `UnauthorizedError` encerra a sessão e volta ao login.

---

## Saúde

### `GET /health`

Verifica se o servidor está no ar. Pública.

**Request**

```http
GET /health
```

**Response 200**

```json
{ "status": "ok", "version": "0.1.0" }
```

---

## Autenticação

### `POST /auth/login`

Autentica e cria uma sessão com dados próprios. Pública.

**Request**

```http
POST /auth/login
Content-Type: application/json

{ "email": "ana@carteira.dev", "password": "123456" }
```

**Response 200**

```json
{
  "token": "tok_0vu34w77pn3oquql7xjtqp5r",
  "user": {
    "id": "usr_01",
    "name": "Ana Ribeiro",
    "email": "ana@carteira.dev",
    "avatarUrl": null,
    "createdAt": "2024-03-11T09:00:00Z"
  }
}
```

**Erros**

| Status | Corpo                                                                                   |
| ------ | --------------------------------------------------------------------------------------- |
| 400    | `{"error":{"code":"bad_request","message":"Malformed JSON body"}}`                      |
| 401    | `{"error":{"code":"invalid_credentials","message":"Invalid email or password"}}`        |
| 422    | `fields: {"email":"must not be empty","password":"must not be empty"}`                  |

No app: o token é guardado em `shared_preferences` (`SharedPrefsSessionStorage`)
e a próxima abertura vai direto para a Home.

### `POST /auth/logout`

Encerra a sessão. Depois disso o token recebe `401 unauthorized`.

**Request**

```http
POST /auth/logout
Authorization: Bearer <token>
```

**Response 204** — sem corpo.

**Erros:** 401. Mesmo com erro, o app apaga a sessão local.

---

## Perfil

### `GET /me`

Devolve o usuário da sessão.

**Request**

```http
GET /me
Authorization: Bearer <token>
```

**Response 200** — um `user`.

```json
{
  "id": "usr_01",
  "name": "Ana Ribeiro",
  "email": "ana@carteira.dev",
  "avatarUrl": null,
  "createdAt": "2024-03-11T09:00:00Z"
}
```

**Erros:** 401.

### `PUT /me`

Atualiza nome e avatar. Os outros campos não mudam.

**Request**

```http
PUT /me
Authorization: Bearer <token>
Content-Type: application/json

{ "name": "Ana R.", "avatarUrl": null }
```

| Campo       | Regra                                                   |
| ----------- | ------------------------------------------------------- |
| `name`      | obrigatório, não vazio; espaços nas pontas são removidos|
| `avatarUrl` | string ou `null`; texto vazio vira `null`               |

**Response 200** — o `user` atualizado.

```json
{
  "id": "usr_01",
  "name": "Ana R.",
  "email": "ana@carteira.dev",
  "avatarUrl": null,
  "createdAt": "2024-03-11T09:00:00Z"
}
```

**Erros**

| Status | Corpo                                  |
| ------ | -------------------------------------- |
| 400    | JSON malformado                        |
| 401    | token inválido                         |
| 422    | `fields: {"name":"must not be empty"}` |

---

## Lançamentos

### `GET /transactions`

Lista os lançamentos da sessão, do mais recente para o mais antigo, com
filtros e paginação.

**Request**

```http
GET /transactions?month=2026-09&type=expense&q=mercado&page=1&pageSize=20
Authorization: Bearer <token>
```

| Parâmetro  | Obrigatório | Padrão | Regra                                         |
| ---------- | ----------- | ------ | --------------------------------------------- |
| `month`    | não         | todos  | `YYYY-MM`                                     |
| `type`     | não         | todos  | `income`, `expense` ou `transfer`             |
| `q`        | não         | —      | busca na `description`, sem diferenciar caixa |
| `page`     | não         | 1      | inteiro ≥ 1                                   |
| `pageSize` | não         | 20     | inteiro de 1 a 100                            |

No app os parâmetros vêm de `TransactionFilter.toQueryParameters()`.

**Response 200** — uma página. `total` conta os itens depois dos filtros.

```json
{
  "items": [
    {
      "id": "tx_0060",
      "type": "expense",
      "amount": 306.7,
      "description": "Mercado Pão de Açúcar",
      "category": "Alimentação",
      "date": "2026-09-27T20:55:00Z",
      "note": "Dividido com a Carla",
      "account": "Nubank",
      "toAccount": null
    }
  ],
  "page": 1,
  "pageSize": 2,
  "total": 20
}
```

Uma página além do fim devolve `items: []`, não erro.

**Erros**

| Status | Corpo                                                                                     |
| ------ | ----------------------------------------------------------------------------------------- |
| 401    | token inválido                                                                            |
| 422    | `fields: {"month":"must be in the format YYYY-MM","page":"must be an integer greater than zero"}` |

### `GET /transactions/:id`

Devolve um lançamento.

**Request**

```http
GET /transactions/tx_0060
Authorization: Bearer <token>
```

**Response 200** — uma `transaction`.

**Erros**

| Status | Corpo                                                                      |
| ------ | -------------------------------------------------------------------------- |
| 401    | token inválido                                                             |
| 404    | `{"error":{"code":"not_found","message":"Transaction tx_9999 not found"}}` |

### `POST /transactions`

Cria um lançamento. O servidor gera o `id`; um `id` no corpo é ignorado (o
app já o remove em `RemoteTransactionRepository.create`).

**Request**

```http
POST /transactions
Authorization: Bearer <token>
Content-Type: application/json

{
  "type": "expense",
  "amount": 89.9,
  "description": "Mercado",
  "category": "Alimentação",
  "date": "2026-09-06T14:32:00Z",
  "note": null,
  "account": "Nubank",
  "toAccount": null
}
```

**Response 201** — a `transaction` criada, já normalizada.

```json
{
  "id": "tx_0081",
  "type": "expense",
  "amount": 89.9,
  "description": "Mercado",
  "category": "Alimentação",
  "date": "2026-09-06T14:32:00Z",
  "note": null,
  "account": "Nubank",
  "toAccount": null
}
```

**Erros:** 400 (JSON malformado), 401 e 422:

```json
{
  "error": {
    "code": "validation",
    "message": "Invalid transaction",
    "fields": {
      "amount": "must be greater than zero",
      "description": "must not be empty",
      "date": "must be an ISO 8601 date",
      "toAccount": "is required for transfers"
    }
  }
}
```

No app, o formulário valida os mesmos campos antes de enviar e, se o servidor
ainda devolver 422, destaca cada campo listado em `fields`.

### `PUT /transactions/:id`

Substitui um lançamento inteiro. O corpo tem o formato do POST; o `id` do
caminho prevalece sobre o do corpo.

**Request**

```http
PUT /transactions/tx_0060
Authorization: Bearer <token>
Content-Type: application/json

{
  "type": "transfer",
  "amount": 500,
  "description": "Reserva",
  "category": null,
  "date": "2026-09-27T20:55:00Z",
  "note": null,
  "account": "Nubank",
  "toAccount": "Itaú"
}
```

**Response 200** — a `transaction` atualizada.

```json
{
  "id": "tx_0060",
  "type": "transfer",
  "amount": 500.0,
  "description": "Reserva",
  "category": null,
  "date": "2026-09-27T20:55:00Z",
  "note": null,
  "account": "Nubank",
  "toAccount": "Itaú"
}
```

**Erros:** 400, 401, 422 (como no POST) e 404 quando o id não existe. A
validação vem antes: corpo inválido para id inexistente recebe 422.

### `DELETE /transactions/:id`

Remove um lançamento.

**Request**

```http
DELETE /transactions/tx_0060
Authorization: Bearer <token>
```

**Response 204** — sem corpo.

**Erros:** 401 e 404 (inclusive ao apagar duas vezes o mesmo id).

---

## Resumo do mês

### `GET /summary`

Soma receitas e despesas de um mês. Transferências ficam de fora.

**Request**

```http
GET /summary?month=2026-09
Authorization: Bearer <token>
```

| Parâmetro | Obrigatório | Padrão    | Regra     |
| --------- | ----------- | --------- | --------- |
| `month`   | não         | mês atual | `YYYY-MM` |

**Response 200**

```json
{ "month": "2026-09", "income": 9526.55, "expense": 5330.04, "balance": 4196.51 }
```

**Erros**

| Status | Corpo                                              |
| ------ | -------------------------------------------------- |
| 401    | token inválido                                     |
| 422    | `fields: {"month":"must be in the format YYYY-MM"}` |

---

## Utilitários

### `POST /reset`

Devolve os dados da sessão ao estado inicial. O token continua válido.

**Request**

```http
POST /reset
Authorization: Bearer <token>
```

**Response 204** — sem corpo. **Erros:** 401.

### Cabeçalhos de simulação

Valem em qualquer rota e são avaliados antes da autenticação. Úteis para
testar os estados de erro e de carregamento das telas.

| Cabeçalho          | Efeito                                                                  |
| ------------------ | ----------------------------------------------------------------------- |
| `X-Delay-Ms: 3000` | usa exatamente esta latência, em ms                                     |
| `X-Fail: 500`      | 500 com `{"error":{"code":"internal","message":"Simulated failure"}}`   |
| `X-Fail: expired`  | 401 com `{"error":{"code":"token_expired","message":"Token has expired"}}` |
| `X-Fail: timeout`  | segura a requisição por 60 s e responde 504 em texto puro               |

Com token válido, uma rota inexistente responde
`404 {"error":{"code":"not_found","message":"Route <caminho> not found"}}`.

## Mapa tela → rotas

| Tela (cena)             | Rotas                                                      |
| ----------------------- | ---------------------------------------------------------- |
| Login                   | `POST /auth/login`                                         |
| Home                    | `GET /me`, `GET /summary`, `GET /transactions?pageSize=5`  |
| Extrato                 | `GET /transactions?type&q&page&pageSize`                   |
| Detalhe do lançamento   | `GET /transactions/:id`, `DELETE /transactions/:id`        |
| Novo / editar lançamento| `POST /transactions`, `PUT /transactions/:id`              |
| Perfil                  | `GET /me`, `PUT /me`, `POST /auth/logout`                  |
