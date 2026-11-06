# Tema, design system e protótipos

## Direção visual: "Neon noturno+"

Uma carteira de "cidade à noite" que também é divertida de usar.

- **Futurista:** o fundo é azul-marinho espacial (escuro) ou lavanda clara
  (claro), iluminado por três auroras suaves. O conteúdo flutua em painéis de
  "vidro" translúcido com contorno fino. O saldo fica num cartão "nebulosa"
  violeta→azul-oceano, com borda iridescente e anéis orbitais. O botão
  principal é uma pílula neon violeta→ciano com brilho.
- **Jovial:** formas arredondadas (pílulas, painéis de 20–28 px, ícones em
  "squircle"), fonte geométrica amigável, cápsulas com entrada escalonada na
  Home e um toque de lima ("spark") racionado, no máximo 2 por tela.
- **Confiável:** valores em dinheiro são sempre cor sólida sobre fundo opaco,
  com algarismos tabulares, sem gradiente ou brilho. Entrada e saída se
  distinguem por sinal (+/−) e seta, nunca só pela cor. Todos os pares de
  texto passam no contraste WCAG AA nos dois temas
  (`test/theme/contrast_test.dart`).

A direção foi escolhida entre três propostas (Neon noturno, Vibe pop e Holo
minimal), avaliadas por adequação ao pedido, acessibilidade e viabilidade. A
vencedora recebeu ideias das outras duas.

## Tema do app

O tema vive no pacote `carteira_design_system` e é montado em três camadas.
As telas nunca usam cor, tamanho ou espaçamento "soltos": tudo sai daqui.

### 1. Tokens (`packages/design_system/lib/src/tokens/`)

**Cores** (`AppColors`): duas paletas com os mesmos 36 campos. Principais:

| Papel               | Claro     | Escuro    | Uso                                          |
| ------------------- | --------- | --------- | -------------------------------------------- |
| `primary`           | `#5A2EE5` | `#B39CFF` | violeta da marca: foco, chip selecionado     |
| `primaryContainer`  | `#E7DFFF` | `#2C1F70` | avatar, pílula "Ver todos"                   |
| `background`        | `#F5F4FF` | `#070A1A` | fundo (lavanda / azul-espacial)              |
| `surface`           | `#FFFFFF` | `#11152D` | diálogos, chips, base do vidro               |
| `onSurface`         | `#15132E` | `#F1F2FF` | texto principal, valor neutro                |
| `onSurfaceMuted`    | `#575380` | `#A9AED8` | texto secundário, rótulos                    |
| `outline`           | `#6F6AA0` | `#7A82C0` | borda de controles (3:1)                     |
| `income`            | `#036A46` | `#3EEFA0` | entradas                                     |
| `expense` / `error` | `#B51C4B` | `#FF7D9C` | saídas, erros                                |
| `transfer`          | `#4A548C` | `#9DB2FF` | ícone de transferência                       |
| `accent`            | `#00657F` | `#3EE6FF` | segundo neon (aqua)                          |
| `spark`             | `#C6F432` | `#D2FF4D` | lima: só preenchimento, no máximo 2 por tela |
| `gradientStart→End` | `#5A2EE5→#0C68C9` | `#B39CFF→#3EE6FF` | botão principal, FAB, logomarca |
| `heroStart→End`     | `#5426E0→#0A55A6` | `#4B1FD6→#0A5592` | cartão de saldo "nebulosa"      |
| `glass`             | branco 78% | `surface` 72% | painéis de vidro                        |

Também há `incomeContainer`, `expenseContainer`, `transferContainer`,
`onKind`, `onGradient`, `onHero`, `glowA/B` etc. A tabela completa está na
página **Tokens** da galeria.

**Fontes:** duas fontes variáveis com licença OFL, embutidas em
`packages/design_system/assets/fonts/`:

- **Plus Jakarta Sans** para toda a interface e para os valores das listas.
- **Space Grotesk** para os números grandes (saldo, detalhe, campo Valor) e os
  títulos de tela.

Todo estilo define `fontWeight` e `fontVariations` (eixo `wght`). Para mudar
o peso, use `AppTypography.weighted(style, 700)`.

**Espaçamento** (`AppSpacing`): grade de 4 pt (`xxs 2 · xs 4 · sm 8 · md 12 ·
lg 16 · xl 24 · xxl 32 · xxxl 48`). Recuo lateral das telas: `screen = 20`.
Também há `panel 20`, `hero 24` e `fabClearance 104`.

**Raios** (`AppRadius`): `sm 8 · md 14 (campos) · lg 20 (painéis, cápsulas) ·
xl 28 (cartão de saldo, diálogos) · pill (botões, chips)`.

**Movimento** (`AppDurations`, `AppMotion`): transições curtas e nada em loop.
O `AppMotion` respeita a preferência de "reduzir animações" do sistema.

### 2. Tema (`lib/src/theme/`)

- `AppTheme.light()` e `AppTheme.dark()` constroem o `ThemeData` Material 3 a
  partir da paleta: `ColorScheme`, `TextTheme` e o tema de cada componente
  (app bar transparente, campos, botões em pílula, chips, segmentos, diálogo,
  snackbar, transições de página).
- `AppSemanticColors` (`context.semanticColors`) guarda as cores de domínio:
  entrada, saída, transferência, os containers de cada tipo e `muted`.
- `AppEffects` (`context.effects`) guarda os gradientes, brilhos, vidro e
  auroras, com os limites de transparência que mantêm o contraste.

### 3. Modo do tema no app

O app **abre no tema escuro**. `AppServices.remote()` cria
`ThemeController(ThemeMode.dark)`. O usuário troca entre Claro, Escuro e
Sistema em **Perfil → Aparência**, e a troca é animada em 300 ms. A escolha
ainda não é salva entre aberturas.

## Componentes

Todos em `packages/design_system/lib/src/components/`, sem dependência do
`carteira_core`: dinheiro e datas chegam já formatados como `String`.

| Componente                | O que é                                                           |
| ------------------------- | ----------------------------------------------------------------- |
| `AppScaffold`             | fundo com aurora, app bar com botões redondos, recuo e FAB        |
| `AppBackdrop`             | as três auroras do fundo (e o "spotlight" do login)               |
| `AppPanel`                | painel de vidro translúcido com contorno fino                     |
| `AppButton`               | primário (pílula neon em gradiente), secundário, destrutivo, texto |
| `AppFab`                  | botão flutuante em gradiente com brilho                           |
| `AppLogoMark`             | logomarca em gradiente (login e app bar da Home)                  |
| `AppTextField`            | campo com rótulo, dica, erro, ícone, prefixo (`R$`) e variante pílula |
| `PasswordField`           | senha com mostrar/ocultar e medidor de força                      |
| `AppAvatar`               | avatar com anel em gradiente                                      |
| `BalanceCard`             | cartão "nebulosa" com saldo, pílula do mês e chips de entrada/saída |
| `MoneyText`               | valor com sinal e cor do tipo; "R$" em meio tamanho nos grandes   |
| `TransactionTile`         | linha da lista: cápsula (Home) ou linha de painel (Extrato)       |
| `KindOrb`, `kindStyleOf`  | ícone e cores únicos de cada tipo de lançamento                   |
| `CategoryBar`             | barra de participação por categoria                               |
| `SectionHeader`           | rótulo com ponto aqua e pílula de ação ("Ver todos")              |
| `StateView`               | carregando / vazio / erro                                         |
| `AppErrorBanner`          | aviso de erro dentro da tela                                      |
| `AppChoiceChips`          | filtro de opção única em chips                                    |
| `TransactionKindSelector` | Saída / Entrada / Transferência com o segmento em cor sólida      |
| `DetailRow`               | rótulo → valor, com ícone em "squircle"                           |
| `ProfileHeader`           | avatar grande, nome, e-mail e pílula "Cliente desde"              |
| `ConfirmDialog` / `showConfirmDialog` | confirmação, com variante destrutiva                  |
| `Gap`, `EmptyDivider`     | espaçamento na escala                                             |

Testes de widget e de contraste: `packages/design_system/test/`.

## Sample app (galeria)

`packages/design_system/example/` é o app de demonstração do design system:

```sh
cd packages/design_system/example
flutter run
```

Páginas: **Tokens** (paleta completa, efeitos, fontes e as regras de uso de
gradiente, brilho e lima), Botões, Campos, Listas, Estados, Filtros e
detalhes e **Protótipos de telas**. O botão no app bar alterna entre claro,
escuro e sistema.

## Protótipos das telas

Em **Galeria → Protótipos de telas**, cada tela do app está montada só com
componentes do design system e dados fixos, navegável entre si:

| Tela            | Conteúdo                                                                |
| --------------- | ----------------------------------------------------------------------- |
| Login           | logomarca com brilho, painel de vidro, e-mail, senha, botão neon        |
| Home            | saudação, cartão nebulosa, cápsulas dos lançamentos, avatar → Perfil, FAB |
| Extrato         | busca em pílula, chips de tipo, painel de vidro com a lista, "Carregar mais" |
| Detalhe         | cabeçalho com brilho do tipo e valor grande, linhas de detalhe, editar, excluir |
| Novo lançamento | seletor de tipo, Valor em Space Grotesk com "R$", demais campos, salvar |
| Perfil          | avatar com anel, dados, aparência (tema), sair                          |

As cenas reais em `lib/scenes/` seguem esses protótipos e ligam cada tela à
API (ver `docs/api.md`, seção "Mapa tela → rotas").
