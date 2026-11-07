# carteira_design_system

Design system do app **Carteira Digital**, na direção visual **"Neon
noturno+"** (versão 2.0.0): tokens, tema Material 3 e componentes.

Uma carteira de "cidade à noite" que também é divertida de usar:

- **Futurista:** fundo azul-marinho espacial (escuro) ou lavanda clara
  (claro) com três auroras suaves, painéis de "vidro" translúcido, cartão de
  saldo "nebulosa" violeta→azul-oceano e botão principal em pílula neon.
- **Jovial:** formas arredondadas (pílulas, painéis de 20–28 px, ícones em
  "squircle"), fonte geométrica amigável e um toque de lima ("spark")
  racionado.
- **Confiável:** valores em dinheiro sempre em cor sólida com algarismos
  tabulares; entrada e saída se distinguem por sinal e seta, nunca só pela
  cor; todos os pares de texto passam no contraste WCAG AA nos dois temas.

O pacote é Flutter puro e não depende do `carteira_core`: dinheiro e datas
chegam **já formatados** como `String`. Não usa nenhum pacote do pub; as duas
fontes vêm embutidas em `assets/fonts/`.

## Como usar no app

1. Dependência por caminho no `pubspec.yaml` do app (as fontes **não** são
   redeclaradas no app: elas são resolvidas pelo pacote):

   ```yaml
   dependencies:
     carteira_design_system:
       path: packages/design_system
   ```

2. No `main()`, registre as licenças das fontes e use os dois temas:

   ```dart
   import 'package:carteira_design_system/carteira_design_system.dart';

   void main() {
     AppFonts.registerLicenses(); // OFL na tela de licenças
     runApp(
       MaterialApp(
         theme: AppTheme.light(),
         darkTheme: AppTheme.dark(),
         themeMode: ThemeMode.dark,
         themeAnimationDuration: const Duration(milliseconds: 300),
         themeAnimationCurve: Curves.easeInOut,
         home: const HomeView(),
       ),
     );
   }
   ```

   Os dois temas registram as extensões `AppSemanticColors` e `AppEffects`.
   Sem elas `context.semanticColors` e `context.effects` disparam um
   `assert`, por isso os componentes só funcionam sob `AppTheme`.

3. Monte cada tela sobre `AppScaffold`, que já desenha a aurora, a app bar
   transparente com botões redondos de 44 px e o recuo lateral de 20:

   ```dart
   AppScaffold(
     title: 'Carteira',
     floatingActionButton: AppFab(
       tooltip: 'Novo lançamento',
       onPressed: () => abrirFormulario(context),
     ),
     body: ListView(
       children: [
         const BalanceCard(
           balance: 'R\$ 4.196,51',
           income: 'R\$ 6.000,00',
           expense: 'R\$ 1.803,49',
         ),
         const SectionHeader(title: 'Hoje'),
         TransactionTile(
           kind: TransactionKind.expense,
           title: 'Mercado',
           amount: 'R\$ 89,90',
           capsule: true,
         ),
         const Gap(AppSpacing.fabClearance),
       ],
     ),
   );
   ```

4. Cores e efeitos sempre pelo tema, nunca literais:

   ```dart
   final semantic = context.semanticColors; // income, expense, transfer,
                                            // warning, muted, *Container, onKind
   final effects = context.effects;         // glass, heroGradient, ctaGlow...
   final kind = kindStyleOf(context, TransactionKind.income);
   // kind.color, kind.container, kind.icon (seta), kind.tone (MoneyTone)
   ```

   Texto usa `Theme.of(context).textTheme` ou os estilos de `AppTypography`;
   espaçamento usa `AppSpacing` / `Gap`; raios usam `AppRadius`. A exceção
   é a geometria própria de um único componente, citada na spec (raios
   avulsos como 12, 16, 18, 24 e 26.5, o alpha de um contorno decorativo):
   ela fica no próprio componente, documentada ali. Cor, sombra, gradiente
   e todo alpha que afeta contraste vêm sempre do tema (`AppEffects`).

## Estrutura

```text
packages/design_system/
├── lib/
│   ├── carteira_design_system.dart   # exporta tudo abaixo
│   └── src/
│       ├── tokens/       # valores brutos
│       ├── theme/        # ThemeData e extensões
│       └── components/   # widgets
├── assets/fonts/         # 2 fontes variáveis + 2 licenças OFL
├── test/                 # testes de widget (components/) e de tema (theme/)
└── example/              # galeria (app de demonstração)
```

**`tokens/`**

| Arquivo | O que define |
| --- | --- |
| `app_colors.dart` | `AppColorPalette` (36 campos) e `AppColors.light` / `AppColors.dark` |
| `app_typography.dart` | os 15 estilos M3, `appBarTitle`, `money*`, `tabularFigures` e `weighted` |
| `app_spacing.dart` | grade de 4 pt (`xxs 2` … `xxxl 48`) e `screen 20`, `panel 20`, `hero 24`, `fabClearance 104` |
| `app_radius.dart` | `sm 8`, `md 14`, `lg 20`, `xl 28`, `pill` e os `*All` |
| `app_durations.dart` | `fast 120`, `normal 220`, `slow 400`, `emphasized 600` ms; entrada escalonada de listas `listEntrance 300` + `stagger 40` por linha (até 5 passos, `listEntranceAt(i)`) |
| `app_motion.dart` | `AppCurves` (`standard`, `playful`) e `AppMotion.of`, que zera durações com "reduzir animações" |
| `app_fonts.dart` | `AppFonts.registerLicenses()` |

**`theme/`**

| Arquivo | O que define |
| --- | --- |
| `app_theme.dart` | `AppTheme.light()` / `AppTheme.dark()`: `ColorScheme`, `TextTheme` e todos os sub-temas |
| `app_semantic_colors.dart` | `AppSemanticColors` e `context.semanticColors` |
| `app_effects.dart` | `AppEffects` (gradientes, brilhos, vidro, auroras e seus limites de alpha) e `context.effects` |

**`components/`**: um arquivo por componente (catálogo abaixo).

## Catálogo de componentes

Toda a API pública tem dartdoc em inglês (o lint `public_member_api_docs`
está ligado); a descrição de cada parâmetro está no código.

### Layout

| Componente | Para quê |
| --- | --- |
| `AppScaffold` | tela padrão: aurora, app bar transparente, recuo de 20, FAB na margem com o conteúdo esmaecido sob ele (`brand` põe a logomarca no título, `spotlight` é o do Login) |
| `AppBackdrop` | as três auroras do fundo e o spotlight opcional; estático, sem toque |
| `AppPanel` | painel de "vidro" (é um `Material`, então o ripple aparece nele); `glow` lava um canto com a cor do tipo |
| `AppLogoMark` | logomarca em gradiente: 72 px no Login (brilho e ponto lima opcional), 28 px na Home |
| `Gap` / `EmptyDivider` | espaço na escala de `AppSpacing`; divisor decorativo com respiro |

### Ações

| Componente | Para quê |
| --- | --- |
| `AppButton` | primário (pílula neon em gradiente com brilho), `.secondary` (contorno, `destructive` em vermelho) e `.text`; `isLoading` troca o rótulo por um spinner |
| `AppFab` | botão flutuante em gradiente com brilho; entra uma vez com leve "pop"; `tooltip` obrigatório (é o rótulo do leitor de tela) |
| `showConfirmDialog` / `ConfirmDialog` | confirmação que devolve `true`/`false`, com variante destrutiva |

### Entrada

| Componente | Para quê |
| --- | --- |
| `AppTextField` | campo com rótulo, dica, erro, ícone, `prefixText` (`'R$ '`), `style` (`AppTypography.moneyInput` no Valor), `maxLines` (Observação, várias linhas) e variante `pill` (busca) |
| `PasswordField` | senha com mostrar/ocultar e medidor de força opcional (`PasswordStrength`) |
| `AppChoiceChips` | filtro de opção única em chips (`ChipOption`) |
| `TransactionKindSelector` | Saída / Entrada / Transf. com o segmento selecionado em cor sólida |

### Dinheiro

| Componente | Para quê |
| --- | --- |
| `MoneyText` | um valor: cor por `MoneyTone`, tamanho por `MoneySize`, sinal `+`/`−` com `signed`; em `display` o "R$" sai em meio tamanho |
| `BalanceCard` | cartão "nebulosa" com o saldo do mês, pílula do mês (spark) e os chips Entradas / Saídas |
| `CategoryBar` | linha de categoria: nome, valor, % e barra proporcional |

### Listas

| Componente | Para quê |
| --- | --- |
| `TransactionTile` | linha de lançamento: dentro de um painel (Extrato) ou `capsule` (Home), com entrada escalonada via `entranceIndex` |
| `KindOrb` / `kindStyleOf` | o mapeamento único de cada `TransactionKind` (cor, container, seta, tom do valor) e o ícone em "squircle" |
| `SectionHeader` | rótulo em caixa alta com ponto aqua e pílula de ação ("Ver todos") |
| `DetailRow` | rótulo → valor de uma tela de detalhe, com ícone opcional |

### Feedback

| Componente | Para quê |
| --- | --- |
| `StateView` | `.loading`, `.empty` (com ponto lima) e `.error` (com "Tentar novamente") |
| `AppErrorBanner` | aviso de erro dentro da tela, anunciado ao leitor de tela |

### Perfil

| Componente | Para quê |
| --- | --- |
| `AppAvatar` | foto ou iniciais dentro do anel em gradiente; brilho a partir de 64 px; `heroTag` opcional |
| `ProfileHeader` | avatar de 96 px, nome, e-mail e pílula de legenda ("Cliente desde…") |

## Regras

Valem para o pacote e para as telas do app; a revisão de código cobra.

**Orçamentos de escassez** (em nenhum outro lugar):

| Efeito | Onde pode aparecer |
| --- | --- |
| Gradiente | `BalanceCard`, `AppButton` primário, `AppFab`, `AppLogoMark`, anel do `AppAvatar` e o preenchimento tonal do `KindOrb` |
| Brilho (sombra colorida) | `BalanceCard`, `AppButton` primário, `AppFab`, `AppLogoMark` e `AppAvatar` a partir de 64 px, chip selecionado |
| Spark (lima) | só preenchimento, nunca texto nem sinal de valor; no máximo **2 pontos por tela** (pílula do mês, ponto do `StateView.empty`, ponto da logomarca no Login) |

**Dinheiro nunca é decorado.** Todo valor passa por `MoneyText` (ou usa
`AppTypography.tabularFigures`): cor sólida sobre fundo opaco ou quase opaco,
algarismos tabulares, sem gradiente, brilho, sombra, shader, emoji, opacidade
parcial ou contagem animada. Valor nunca é cortado com reticências: ele
encolhe (`FittedBox`). Entrada e saída sempre levam sinal (`+` / `−`) e seta
(para baixo / para cima), nunca só a cor.

**Fontes variáveis.** Todo estilo define `fontWeight` **e** o eixo `wght`.
Para mudar o peso use `AppTypography.weighted(style, 700)`: um
`copyWith(fontWeight:)` sozinho mantém o eixo antigo e o texto sai no peso
anterior.

**Vidro sem blur.** Não há `BackdropFilter` em lugar nenhum. O "vidro" é uma
superfície translúcida com contorno fino sobre a aurora do `AppBackdrop`.
`InkWell`/`ListTile` sobre vidro ficam dentro de um `Material` (o `AppPanel`
já é um), senão o ripple some.

**Nada em loop.** Cada animação decorativa roda uma vez (entrada, troca de
estado, toque), dura no máximo 600 ms e passa por `AppMotion.of`, que a
desliga quando o sistema pede "reduzir animações". A única exceção são os
indicadores de progresso indeterminados de `StateView.loading` e
`AppButton(isLoading: true)`: o `CircularProgressIndicator` gira enquanto a
operação dura, como manda o Material. Em teste de widget, numa tela ou botão
carregando use `pump()` (ou `pump(duração)`), não `pumpAndSettle`, que
esperaria para sempre; fora desses estados `pumpAndSettle` termina.

**Contraste.** Os alphas de `AppEffects` marcados como "AA cap" (auroras,
spotlight, blob e órbitas do cartão, brilho do tipo) não podem subir, e o
vidro não muda sem refazer a conta: `test/theme/contrast_test.dart` compõe
os piores fundos (aurora, vidro, nebulosa, chips do cartão) nos dois temas e
confere cada par de texto. Bordas de controles usam `outline` (3:1);
`outlineVariant` é só decorativo.

**Outros cuidados.**

- O `FilledButton` global é sólido; o gradiente só existe no `AppButton`
  primário, então diálogos nunca o herdam.
- Uma `heroTag` por rota: só a Home (`AppAvatar.heroTag`) e o Perfil
  (`ProfileHeader.avatarHeroTag`) passam `'profile-avatar'`.
- `ColorScheme.secondary` é o aqua (`accent`), não a cor de transferência.

## Testes, análise e galeria

```sh
cd packages/design_system
flutter analyze                              # deve dizer "No issues found!"
flutter test                                 # widgets e tema
flutter test test/theme/contrast_test.dart   # só o contraste WCAG
```

- `test/components/`: ao menos um arquivo por componente (contratos de
  texto, ícone, cor, semântica, opções e movimento reduzido).
- `test/tokens/`: `AppMotion`, `AppDurations` e o registro das licenças das
  fontes (`AppFonts.registerLicenses`).
- `test/theme/`: `app_theme_test.dart` (paleta → `ThemeData`) e
  `contrast_test.dart` (pares de cor nos dois temas).
- `test/test_helpers.dart`: `wrap()` monta o widget sob `AppTheme`.

A galeria (`example/`) é o app de demonstração:

```sh
cd packages/design_system/example
flutter run
```

Páginas: **Tokens** (paleta, gradientes, brilhos, vidro, auroras e sombras,
tipos, orçamentos, tipografia com eixos e licenças, raios, espaçamento e
movimento), Botões, Campos, Listas, Estados,
Filtros e detalhes e **Protótipos de telas**. O botão da app bar alterna
entre claro, escuro e sistema; a galeria abre no escuro.

## Fontes e licenças

| Fonte | Arquivo | Eixo | Uso |
| --- | --- | --- | --- |
| Plus Jakarta Sans | `PlusJakartaSans-Variable.ttf` | `wght` 200–800 | toda a interface e os valores das listas |
| Space Grotesk | `SpaceGrotesk-Variable.ttf` | `wght` 300–700 | saldo e valor do detalhe, títulos de tela, campo Valor, iniciais do avatar |

As duas são da coleção do Google Fonts e usam a **SIL Open Font License
1.1** (copyright 2020 dos respectivos "Project Authors"). A OFL permite usar,
embutir e redistribuir as fontes junto com o app, desde que a licença as
acompanhe: por isso `OFL-PlusJakartaSans.txt` e `OFL-SpaceGrotesk.txt` são
assets do pacote e `AppFonts.registerLicenses()` os coloca na tela de
licenças (`showLicensePage`). As fontes não podem ser vendidas sozinhas.

Mais contexto (paleta completa, decisões de design e protótipos das telas) em
[`docs/tema-e-design-system.md`](../../docs/tema-e-design-system.md).
