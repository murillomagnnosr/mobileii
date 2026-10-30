# Tema, design system e protótipos

## Tema do app

O tema vive no pacote `carteira_design_system` e é montado em três camadas.
As telas nunca usam cor, tamanho ou espaçamento "soltos": tudo sai daqui.

### 1. Tokens (`packages/design_system/lib/src/tokens/`)

**Cores** (`AppColors`) — duas paletas com os mesmos nomes:

| Papel              | Claro       | Escuro      | Uso                              |
| ------------------ | ----------- | ----------- | -------------------------------- |
| `primary`          | `#0F6E8A`   | `#5FB3CC`   | ações, foco, destaque            |
| `primaryContainer` | `#DDEEF4`   | `#15414E`   | chip/segmento selecionado, avatar|
| `background`       | `#F7F6F3`   | `#14171A`   | fundo das telas                  |
| `surface`          | `#FFFFFF`   | `#1C2126`   | cards, campos, diálogos          |
| `onSurface`        | `#1E2229`   | `#E8E9EB`   | texto principal                  |
| `onSurfaceMuted`   | `#6B7078`   | `#9AA1AA`   | texto secundário                 |
| `outline`          | `#D9D6D0`   | `#373E46`   | bordas e divisórias              |
| `income`           | `#2E7D5B`   | `#5FBF93`   | entradas                         |
| `expense`          | `#B4483A`   | `#E07A6C`   | saídas                           |
| `transfer`         | `#6B7480`   | `#9AA4B0`   | transferências                   |
| `warning`          | `#B26A1B`   | `#E0A24A`   | alertas, senha razoável          |
| `error`            | `#B4483A`   | `#E07A6C`   | erros de formulário              |

Fundo cinza-quente com acento azul-petróleo; verde e vermelho só para
dinheiro entrando e saindo.

**Tipografia** (`AppTypography`) — fonte da plataforma, escala de
`displayLarge` 40/700 (saldo) a `labelSmall` 11/600 (cabeçalho de seção).
Valores em dinheiro usam algarismos tabulares para alinhar colunas.

**Espaçamento** (`AppSpacing`) — grade de 4 pt: `xxs 2 · xs 4 · sm 8 · md 12 ·
lg 16 · xl 24 · xxl 32 · xxxl 48`; recuo lateral das telas = `lg`.

**Raios** (`AppRadius`) — `sm 6 · md 10 (campos, botões) · lg 16 (cards,
diálogos) · pill (chips, barras)`.

**Movimento** (`AppDurations`) — `fast 120 ms · normal 220 ms · slow 400 ms`.

### 2. Tema (`lib/src/theme/`)

- `AppTheme.light()` e `AppTheme.dark()` constroem o `ThemeData` Material 3 a
  partir de uma paleta: `ColorScheme`, `TextTheme` e o tema de cada
  componente (app bar plano, cards com borda, campos preenchidos, botões de
  48 pt, chips em pílula, segmented button, snackbar flutuante etc.).
- `AppSemanticColors` é um `ThemeExtension` com as cores que o
  `ColorScheme` não tem (`income`, `expense`, `transfer`, `warning`, `muted`),
  lidas com `context.semanticColors`.

### 3. Modo do tema no app

`lib/app/theme_controller.dart` guarda o `ThemeMode` escolhido
(**claro por padrão**, escuro ou do sistema). O `MaterialApp` em
`lib/main.dart` escuta o controller; o usuário troca em **Perfil → Aparência**.

## Componentes

Todos em `packages/design_system/lib/src/components/`, sem dependência do
`carteira_core`: dinheiro e datas chegam já formatados como `String`.

| Componente                | O que é                                                    |
| ------------------------- | ---------------------------------------------------------- |
| `AppScaffold`             | Scaffold padrão: app bar plano, recuo lateral, FAB         |
| `AppButton`               | botão primário / secundário / texto, com estado carregando |
| `AppTextField`            | campo de texto com label, dica, erro e ícone               |
| `PasswordField`           | senha com mostrar/ocultar e medidor de força               |
| `AppAvatar`               | avatar com imagem ou iniciais                              |
| `BalanceCard`             | card de saldo do mês com entradas e saídas                 |
| `MoneyText`               | valor monetário colorido por tom, com sinal                |
| `TransactionTile`         | linha da lista de lançamentos                              |
| `CategoryBar`             | barra de participação por categoria                        |
| `SectionHeader`           | rótulo de seção com ação ("Ver todos")                     |
| `StateView`               | estados de carregando / vazio / erro                       |
| `Gap`, `EmptyDivider`     | espaçamento na escala                                      |
| `AppChoiceChips` *(novo)* | filtro de opção única em chips                             |
| `TransactionKindSelector` *(novo)* | seletor Saída / Entrada / Transferência           |
| `DetailRow` *(novo)*      | linha rótulo → valor da tela de detalhe                    |
| `ProfileHeader` *(novo)*  | avatar, nome e e-mail do perfil                            |
| `ConfirmDialog` / `showConfirmDialog` *(novo)* | confirmação, com variante destrutiva  |

Testes de widget: `packages/design_system/test/`.

## Sample app (galeria)

`packages/design_system/example/` é o app de demonstração do design system:

```sh
cd packages/design_system/example
flutter run
```

Páginas: Tokens, Botões, Campos, Listas, Estados, **Filtros e detalhes** e
**Protótipos de telas**. O botão no app bar alterna claro / escuro / sistema.

## Protótipos das telas

Em **Galeria → Protótipos de telas** cada tela do app está montada só com
componentes do design system e dados fixos, navegável entre si:

| Tela                  | Conteúdo                                                        |
| --------------------- | --------------------------------------------------------------- |
| Login                 | e-mail, senha com mostrar/ocultar, botão Entrar                 |
| Home                  | saudação, `BalanceCard`, últimos lançamentos, avatar → Perfil, FAB → Novo |
| Extrato               | busca, chips Todos/Entradas/Saídas/Transferências, lista, "Carregar mais" |
| Detalhe               | valor em destaque, linhas de detalhe, editar, excluir com confirmação |
| Novo lançamento       | seletor de tipo, valor, descrição, conta, destino (transferência) ou categoria, data, observação |
| Perfil                | cabeçalho, editar nome, aparência (tema), sair                  |

As cenas reais em `lib/scenes/` seguem esses protótipos e ligam cada tela à
API (ver `docs/api.md`, seção "Mapa tela → rotas").
