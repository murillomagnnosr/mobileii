# Changelog

Mudanças do `carteira_design_system`. As versões seguem
[SemVer](https://semver.org/lang/pt-BR/): a major sobe quando um app que usa
o pacote precisa mudar código.

## 2.0.0 — 2026-11-06

Redesenho completo na direção visual **"Neon noturno+"** (futurista, jovial e
confiável), escolhida entre três propostas. A API dos componentes existentes
foi mantida; as quebras estão nos tokens e no tema.

### Quebras

- `AppColorPalette` passou de 16 para **36 campos obrigatórios**
  (`outlineVariant`, `accent`/`onAccent`, `spark`/`onSpark`, containers por
  tipo, `onKind`, gradiente do CTA, nebulosa do cartão, auroras e vidro).
  Paletas novas nos dois temas: violeta e aqua sobre lavanda clara / azul
  espacial, no lugar do azul-petróleo.
- `AppSemanticColors` ganhou `incomeContainer`, `expenseContainer`,
  `transferContainer` e `onKind` (obrigatórios).
- `ColorScheme.secondary` agora é o aqua (`accent`); a cor de transferência
  passou para `tertiary`.
- `AppSpacing.screen` foi de 16 para **20**.
- `AppRadius`: `sm` 6 → 8, `md` 10 → 14, `lg` 16 → 20.
- Tipografia trocou a fonte da plataforma por duas fontes embutidas, com uma
  nova escala de tamanhos, alturas e pesos.

### Tokens

- Fontes variáveis OFL embutidas em `assets/fonts/`: **Plus Jakarta Sans**
  (interface e valores de lista) e **Space Grotesk** (números grandes,
  títulos de tela, campo Valor, iniciais do avatar).
- `AppTypography`: os 15 estilos do Material 3, `appBarTitle`,
  `moneySmall`/`moneyMedium`/`moneyLarge`/`moneyInput`, as constantes
  `sansFamily`, `displayFamily` e `fontPackage`, e `weighted()`, que muda o
  peso e o eixo `wght` juntos.
- `AppFonts.registerLicenses()` publica as duas licenças OFL na tela de
  licenças.
- `AppColorPalette.entries` lista `(nome, cor)` de todos os campos (galeria e
  teste de contraste).
- `AppSpacing.panel` (20), `AppSpacing.hero` (24) e
  `AppSpacing.fabClearance` (104); `AppRadius.xl` (28) e `xlAll`.
- `AppDurations.emphasized` (600 ms), `AppCurves` e `AppMotion.of()`, que
  zera as durações quando o sistema pede "reduzir animações".
- `AppDurations.listEntrance` (300 ms), `stagger` (40 ms),
  `staggerMaxSteps` (5) e `listEntranceAt(i)`, usados pela entrada
  escalonada do `TransactionTile`.

### Tema

- `AppEffects` (`context.effects`): gradientes, brilhos, vidro, auroras e
  spark, com os alphas que mantêm o contraste ("AA caps"). É interpolado na
  troca de tema, então cartão, CTA e auroras fazem a transição suavemente.
- `AppTheme` reescrito: app bar transparente (fundo só ao rolar) com estilo
  da barra de status explícito, transições de página FadeForwards
  (Android) / Cupertino (iOS), `InkSparkle`, e todos os sub-temas
  (campos, botões em pílula, chips, segmentos, card de vidro, diálogo, bottom
  sheet, snackbar, switch, progresso, date picker). O `FilledButton` global
  continua sólido.

### Componentes

- Novos: `AppBackdrop`, `AppPanel`, `AppFab` (com `tooltip` obrigatório,
  que é o rótulo do leitor de tela), `AppLogoMark`,
  `AppErrorBanner`, `KindOrb` e `kindStyleOf` / `KindStyle` (o mapeamento
  único de cor, container, seta e tom de cada tipo de lançamento).
- Parâmetros novos (opcionais): `AppAvatar.heroTag`,
  `AppButton.destructive`, `AppScaffold.spotlight` e `brand`,
  `AppTextField.style`, `prefixText`, `pill` e `floatingLabelBehavior`,
  `BalanceCard.animateIn`, `MoneyText.scaleDown`,
  `ProfileHeader.avatarHeroTag`, `TransactionTile.capsule` e
  `entranceIndex`, `AppChoiceChips.padding`, `ConfirmDialog.icon` (e
  `showConfirmDialog(icon:)`).
- Todos os componentes existentes foram restilizados: CTA em pílula neon com
  brilho, cartão de saldo "nebulosa" com pílula do mês, "R$" em meio tamanho
  nos valores `display`, valores que encolhem em vez de serem cortados, setas
  de tipo obrigatórias, segmento de tipo selecionado em cor sólida, avatar
  com anel em gradiente, estados com "squircle".
- `StateView.empty` usa `Icons.inbox_rounded` por padrão.
- Nenhuma animação decorativa roda em loop; todas passam por
  `AppMotion.of`. Só os indicadores de progresso indeterminados
  (`StateView.loading`, `AppButton.isLoading`) giram enquanto carregam.

### Qualidade

- `test/theme/contrast_test.dart`: confere o contraste WCAG AA de cada par de
  texto nos piores fundos compostos (aurora, vidro, nebulosa, chips) dos dois
  temas e trava os limites de alpha.
- Lint `public_member_api_docs` ligado: toda a API pública tem dartdoc.
- Testes de widget para todos os componentes, inclusive as opções
  (`ConfirmDialog` não destrutivo, seletor desabilitado, `MoneySize.display`,
  `scaleDown`, cápsula e entrada do `TransactionTile`, `BalanceCard` sem
  animação) e o movimento reduzido; testes de `AppMotion`, `AppDurations` e
  `AppFonts.registerLicenses` em `test/tokens/`.
- README reescrito para o design system atual; galeria com a página Tokens
  (paleta, efeitos, vidro, auroras e sombras, fontes com eixos e licenças e
  orçamentos de uso) e protótipos das telas novas.

## 1.0.0 — 2026-09-26

Versão inicial, com o visual azul-petróleo e a fonte da plataforma.

- Tokens: `AppColors` (paletas clara e escura, 16 campos), `AppSpacing`
  (grade de 4 pt, `screen` 16), `AppRadius`, `AppTypography` (com
  `tabularFigures` para valores) e `AppDurations`.
- Tema: `AppTheme.light()` / `AppTheme.dark()` em Material 3 e
  `AppSemanticColors` (`income`, `expense`, `transfer`, `warning`, `muted`)
  com `context.semanticColors`.
- Componentes: `AppScaffold`, `AppButton` (primário, secundário, texto,
  carregando), `AppTextField`, `PasswordField` (com medidor de força),
  `AppAvatar`, `BalanceCard`, `MoneyText`, `TransactionTile`, `CategoryBar`,
  `SectionHeader`, `StateView`, `Gap` e `EmptyDivider`.
- Galeria em `example/` (Tokens, Botões, Campos, Listas, Estados) e testes de
  widget.

Ampliada em 2026-10-30, sem mudar a versão: `AppChoiceChips`,
`TransactionKindSelector`, `DetailRow`, `ProfileHeader` e
`showConfirmDialog` / `ConfirmDialog`; temas de chips, segmented button e
progresso no `AppTheme`; páginas "Filtros e detalhes" e "Protótipos de
telas" na galeria.
