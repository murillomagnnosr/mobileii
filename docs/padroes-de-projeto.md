# Padrões de projeto usados

Onde cada padrão estudado no semestre aparece no app e no design system.

## Arquitetura das cenas: MVVM + Coordinator + Factory

Cada tela em `lib/scenes/<cena>/` tem sempre quatro arquivos:

```
<cena>_view.dart         View: só desenha e repassa eventos
<cena>_view_model.dart   ViewModel (ChangeNotifier): estado + ações
<cena>_coordinator.dart  Coordinator: para onde ir depois
<cena>_factory.dart      Factory: monta tudo e injeta as dependências
```

Cenas: `login`, `home`, `transactions` (extrato), `transaction_detail`,
`transaction_form` (criar/editar) e `profile`.

- **MVVM.** A View escuta o ViewModel com `ListenableBuilder` e não tem
  regra de negócio; o ViewModel não importa widgets de tela e é testado sem
  Flutter rodando (`test/scenes/`).
- **Coordinator.** A navegação sai do ViewModel: ele chama
  `coordinator.showTransaction(id)` ou `onSessionExpired()` e não sabe qual
  rota abre. Os coordinators são interfaces (`abstract interface class`), e o
  teste usa um coordinator falso. Os que tratam sessão implementam
  `SessionCoordinator` (`lib/scenes/shared/`).
- **Factory.** `XFactory.make(services)` cria ViewModel, Coordinator e View.
  É chamada fora dos builders de rota (`pushScene` recebe a cena pronta) para
  que um hot reload não recrie o ViewModel.

## Injeção de dependência

`AppServices` (`lib/app/app_services.dart`) é a raiz de composição: monta os
repositórios uma vez e as Factories os entregam pelo construtor
(`this._auth`, `this._transactions`…). Trocar API real por memória ou fake
acontece num lugar só.

## Repository

`AuthRepository`, `UserRepository` e `TransactionRepository` são interfaces no
`carteira_core`, com duas implementações cada: `Remote*` (HTTP) e
`InMemory*` (dados de exemplo/testes). As cenas dependem só da interface.

## Result (tratamento de erro sem exceção)

Os repositórios devolvem `Result<T>` — classe selada com `Ok` e `Failure` —
e nunca lançam. Os erros são a hierarquia selada `AppError` (`NetworkError`,
`UnauthorizedError`, `ValidationError`…), e o `switch` dos ViewModels é
exaustivo, como em `TransactionFormViewModel.submit`.

## Adapter

- `ApiClient` adapta o `dio` ao contrato da API: põe o token e converte
  status/erros em `AppError`.
- `lib/scenes/shared/transaction_display.dart` adapta o modelo do core
  (`Transaction`, `TransactionType`) aos tipos do design system
  (`TransactionKind`), que não conhece o domínio.

## Factory Method

- `Transaction.fromJson` escolhe `Income`, `Expense` ou `Transfer` pelo
  campo `type`.
- `TransactionFormViewModel._build` faz o caminho inverso a partir do tipo
  escolhido no formulário.
- `MoneyFormatter.forCurrency` devolve o formatador da moeda.

## Strategy

`MoneyFormatter` com `BrlFormatter`, `UsdFormatter` e `EurFormatter`: mesma
interface, implementação escolhida em tempo de execução.

## Observer

- ViewModels são `ChangeNotifier`; as Views reconstroem ao `notifyListeners`.
- `ThemeController` é um `ValueNotifier<ThemeMode>` que o `MaterialApp`
  escuta: o perfil troca o tema e o app inteiro reage.
- `TransactionRepository.watch()` emite a lista após cada mutação.

## Encapsulamento e imutabilidade

Modelos imutáveis com `copyWith`, igualdade por valor e campos privados
(`Session._token`). Os ViewModels expõem só getters; o estado muda pelos
métodos de ação.

## Design system: tokens → tema → componentes

- **Design tokens** como única fonte de cor, tipografia, espaçamento e raio.
- `ThemeExtension` (`AppSemanticColors`) para cores de domínio.
- Componentes "burros": recebem texto já formatado e callbacks, sem estado
  de negócio (só estado de UI, como mostrar/ocultar senha).
- Construtores nomeados como variações (`AppButton.secondary`,
  `StateView.error`, `Gap.md`).
- Composição: os protótipos de telas da galeria são feitos só de componentes.
