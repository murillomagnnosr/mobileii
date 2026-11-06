import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

/// Documents the tokens of the active theme: palette, effects, kind styles,
/// scarcity budgets, type, radii, spacing and motion.
///
/// Every value is read from the tokens or the theme, never repeated here.
/// The page is exempt from the spark budget because it documents the colour.
class TokensPage extends StatelessWidget {
  const TokensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Tokens',
      actions: const [ThemeModeButton()],
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: const [
          SectionHeader(title: 'Paleta'),
          _PaletteGrid(),
          SectionHeader(title: 'Gradientes'),
          _Gradients(),
          SectionHeader(title: 'Brilhos'),
          _Glows(),
          SectionHeader(title: 'Tipos de lançamento'),
          _Kinds(),
          SectionHeader(title: 'Orçamentos'),
          _Budgets(),
          SectionHeader(title: 'Tipografia'),
          _Typography(),
          SectionHeader(title: 'Raios'),
          _Radii(),
          SectionHeader(title: 'Espaçamento'),
          _Spacing(),
          SectionHeader(title: 'Movimento'),
          _Motion(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers

/// `#RRGGBB`, or `#AARRGGBB` when the colour is translucent.
String _hex(Color color) {
  final argb = color.toARGB32();
  final hex = argb.toRadixString(16).padLeft(8, '0').toUpperCase();
  return (argb >> 24) == 0xFF ? '#${hex.substring(2)}' : '#$hex';
}

/// `0.45` -> `0.45`, `1.0` -> `1`.
String _number(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();

/// `size/weight` of a text style, e.g. `42/700`.
String _metrics(TextStyle style) =>
    '${_number(style.fontSize ?? 0)}/${style.fontWeight?.value ?? 400}';

/// Muted bodySmall with tabular digits: hex codes and measurements.
TextStyle _mono(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.bodySmall!.copyWith(
    color: theme.colorScheme.onSurfaceVariant,
    fontFeatures: AppTypography.tabularFigures,
  );
}

/// Small heading inside a section.
class _Subheading extends StatelessWidget {
  const _Subheading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Palette

class _PaletteGrid extends StatelessWidget {
  const _PaletteGrid();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Floored so rounding never pushes the second tile to a new run.
        final width = ((constraints.maxWidth - AppSpacing.md) / 2)
            .floorToDouble();
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final (name, color) in palette.entries)
              SizedBox(
                width: width,
                child: _SwatchTile(name: name, color: color),
              ),
          ],
        );
      },
    );
  }
}

class _SwatchTile extends StatelessWidget {
  const _SwatchTile({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 72,
          width: double.infinity,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: AppRadius.mdAll,
              // The checkerboard shows through translucent colours (glass).
              child: CustomPaint(
                painter: _CheckerPainter(
                  light: scheme.surface,
                  dark: scheme.outlineVariant,
                ),
                child: ColoredBox(color: color),
              ),
            ),
          ),
        ),
        const Gap(6),
        Text(
          name,
          style: theme.textTheme.labelMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(_hex(color), style: _mono(context)),
      ],
    );
  }
}

/// 6px checkerboard behind the swatches.
class _CheckerPainter extends CustomPainter {
  const _CheckerPainter({required this.light, required this.dark});

  static const double _cell = 6;

  final Color light;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = light);
    final paint = Paint()..color = dark;
    for (var row = 0; row * _cell < size.height; row++) {
      for (var col = row.isEven ? 0 : 1; col * _cell < size.width; col += 2) {
        canvas.drawRect(
          Rect.fromLTWH(col * _cell, row * _cell, _cell, _cell),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter oldDelegate) =>
      oldDelegate.light != light || oldDelegate.dark != dark;
}

// ---------------------------------------------------------------------------
// 2. Gradients

class _Gradients extends StatelessWidget {
  const _Gradients();

  /// Stop colours, plus the stop positions when the gradient sets them.
  static String _stops(Gradient gradient) {
    final colors = gradient.colors.map(_hex).join(' → ');
    final stops = gradient.stops;
    if (stops == null) return colors;
    return '$colors\n${stops.map(_number).join(' / ')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = context.effects;
    final mono = _mono(context);
    final gradients = <(String, Gradient)>[
      ('heroGradient', e.heroGradient),
      ('heroRim', e.heroRim),
      ('ctaGradient', e.ctaGradient),
      ('ringGradient', e.ringGradient),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MiniNebula(),
        const Gap.md(),
        Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: e.ctaGradient,
                  borderRadius: AppRadius.pillAll,
                ),
                child: SizedBox(
                  height: 56,
                  child: Center(
                    child: Text(
                      'ctaGradient',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: e.onGradient,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Gap.md(),
            SizedBox.square(
              dimension: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: e.ringGradient,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const Gap.lg(),
        for (final (name, gradient) in gradients)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 108,
                  child: Text(name, style: theme.textTheme.labelMedium),
                ),
                Expanded(child: Text(_stops(gradient), style: mono)),
              ],
            ),
          ),
      ],
    );
  }
}

/// 120px BalanceCard skeleton: rim, nebula fill, cyan blob and orbit rings.
class _MiniNebula extends StatelessWidget {
  const _MiniNebula();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = context.effects;
    return SizedBox(
      height: 120,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.xlAll,
          gradient: e.heroRim,
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26.5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(gradient: e.heroGradient),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: e.wash(
                      e.heroBlob,
                      center: const Alignment(0.9, -1),
                      radius: 0.8,
                    ),
                  ),
                ),
                Positioned(
                  left: -90,
                  bottom: -130,
                  width: 260,
                  height: 260,
                  child: _Orbit(color: e.heroOrbit),
                ),
                Positioned(
                  left: -50,
                  bottom: -90,
                  width: 180,
                  height: 180,
                  child: _Orbit(color: e.heroOrbit.withValues(alpha: 0.04)),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.hero),
                  child: Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Text(
                      'heroGradient · heroRim · heroBlob · heroOrbit',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: e.onHeroMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Orbit extends StatelessWidget {
  const _Orbit({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Glows

class _Glows extends StatelessWidget {
  const _Glows();

  @override
  Widget build(BuildContext context) {
    final e = context.effects;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.xl,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          _Recipe(
            name: 'ctaGlow',
            shadows: e.ctaGlow,
            child: AppButton(
              label: 'Entrar',
              expanded: false,
              onPressed: () {},
            ),
          ),
          _Recipe(
            name: 'fabGlow',
            shadows: e.fabGlow,
            child: AppFab(tooltip: 'Novo lançamento', onPressed: () {}),
          ),
          _Recipe(
            name: 'avatarGlow',
            shadows: e.avatarGlow,
            child: const AppAvatar(name: 'Ana Ribeiro', size: 96),
          ),
        ],
      ),
    );
  }
}

/// A glowing sample labelled with its recipe name, alpha and blur.
class _Recipe extends StatelessWidget {
  const _Recipe({
    required this.name,
    required this.shadows,
    required this.child,
  });

  final String name;
  final List<BoxShadow> shadows;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shadow = shadows.first;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const Gap.md(),
        Text(name, style: Theme.of(context).textTheme.labelMedium),
        Text(
          'α ${shadow.color.a.toStringAsFixed(2)} · '
          'blur ${_number(shadow.blurRadius)}',
          style: _mono(context),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Transaction kinds

class _Kinds extends StatelessWidget {
  const _Kinds();

  static const _kinds = [
    (TransactionKind.expense, 'Saída'),
    (TransactionKind.income, 'Entrada'),
    (TransactionKind.transfer, 'Transferência'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onKind = context.semanticColors.onKind;
    final mono = _mono(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final (kind, label) in _kinds) ...[
              Column(
                children: [
                  KindOrb(kind: kind),
                  const Gap(6),
                  Text(label, style: mono),
                ],
              ),
              const Gap.xl(),
            ],
          ],
        ),
        const _Subheading('Segmento selecionado (cor sólida + onKind)'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (kind, label) in _kinds)
              Builder(
                builder: (context) {
                  final k = kindStyleOf(context, kind);
                  return DecoratedBox(
                    decoration: ShapeDecoration(
                      color: k.color,
                      shape: const StadiumBorder(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(k.icon, size: 18, color: onKind),
                          const Gap(6),
                          Text(
                            label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: onKind,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        const _Subheading('Containers (cor do tipo sobre o container)'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (kind, label) in _kinds)
              Builder(
                builder: (context) {
                  final k = kindStyleOf(context, kind);
                  return DecoratedBox(
                    decoration: ShapeDecoration(
                      color: k.container,
                      shape: const StadiumBorder(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 6,
                      ),
                      child: Text(
                        label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: k.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        const Gap.md(),
        Text(
          'A cor nunca é o único sinal: a seta e o sinal (+ / −) acompanham '
          'o tipo em toda parte.',
          style: mono,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Scarcity budgets (spec section 1)

class _Budgets extends StatelessWidget {
  const _Budgets();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = context.effects;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BudgetPanel(
          title: 'Gradiente',
          marker: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: e.ctaGradient.colors,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          body:
              'Só em: BalanceCard (nebulosa e aro), CTA (AppButton primary), '
              'AppFab, AppLogoMark (Login 72px, AppBar da Home 28px), anel do '
              'AppAvatar e preenchimento do KindOrb (gradiente tonal do mesmo '
              'matiz, não o da marca). Em nenhum outro lugar.',
        ),
        const Gap.md(),
        _BudgetPanel(
          title: 'Brilho (sombra colorida)',
          marker: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(9),
              boxShadow: e.ctaGlow,
            ),
          ),
          body:
              'Só em: BalanceCard, CTA, AppFab, AppLogoMark a 72px, AppAvatar '
              'a partir de 64px e ChoiceChip selecionado (brilho pequeno de '
              'elevação M3). Nunca em linhas de lista, painéis, barras de '
              'categoria ou texto de dinheiro.',
        ),
        const Gap.md(),
        _BudgetPanel(
          title: 'Faísca (lima)',
          marker: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: e.spark,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: const SizedBox.square(dimension: 14),
            ),
          ),
          body:
              'Só como ponto sólido: a pílula do mês no herói, o ponto do '
              'StateView.empty e o ponto do logotipo do Login. No máximo 2 '
              'por tela (Home com lista vazia = pílula + ponto). É sempre '
              'preenchimento, nunca cor de texto, e nunca indica estado de '
              'dinheiro. O trecho lima do anel do avatar não conta. Esta '
              'página é exceção porque documenta a cor.',
        ),
      ],
    );
  }
}

class _BudgetPanel extends StatelessWidget {
  const _BudgetPanel({
    required this.title,
    required this.marker,
    required this.body,
  });

  final String title;

  /// 28px sample of the budgeted effect.
  final Widget marker;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox.square(dimension: 28, child: marker),
              const Gap(10),
              Expanded(child: Text(title, style: text.titleSmall)),
            ],
          ),
          const Gap.sm(),
          Text(body, style: text.bodyMedium),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Typography

class _Typography extends StatelessWidget {
  const _Typography();

  static bool _isDisplay(TextStyle style) =>
      style.fontFamily?.endsWith(AppTypography.displayFamily) ?? false;

  /// A sample that matches where the slot is used.
  static String _sample(String slot) => switch (slot) {
    'headlineMedium' => 'Entrar',
    'headlineSmall' || 'titleLarge' => 'Olá, Ana',
    'titleMedium' => 'Mercado Pão de Açúcar',
    'titleSmall' => 'Salário',
    'bodyLarge' => 'Acesse sua carteira digital',
    'bodyMedium' => 'Descrição do lançamento',
    'bodySmall' => '27/10 · Nubank',
    'labelLarge' => 'Salvar',
    'labelMedium' => 'Ver todos',
    'labelSmall' => 'ÚLTIMOS LANÇAMENTOS',
    _ => 'Carteira',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final onSurface = theme.colorScheme.onSurface;
    final slots = <(String, TextStyle)>[
      ('displayLarge', t.displayLarge!),
      ('displayMedium', t.displayMedium!),
      ('displaySmall', t.displaySmall!),
      ('headlineLarge', t.headlineLarge!),
      ('headlineMedium', t.headlineMedium!),
      ('headlineSmall', t.headlineSmall!),
      ('titleLarge', t.titleLarge!),
      ('titleMedium', t.titleMedium!),
      ('titleSmall', t.titleSmall!),
      ('bodyLarge', t.bodyLarge!),
      ('bodyMedium', t.bodyMedium!),
      ('bodySmall', t.bodySmall!),
      ('labelLarge', t.labelLarge!),
      ('labelMedium', t.labelMedium!),
      ('labelSmall', t.labelSmall!),
    ];

    Widget specimen(String name, TextStyle style) => _Specimen(
      label: '$name · ${_metrics(style)}',
      child: Text(_sample(name), style: style),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Subheading('Plus Jakarta Sans · interface e valores de lista'),
        for (final (name, style) in slots)
          if (!_isDisplay(style)) specimen(name, style),
        const _Subheading('Space Grotesk · números grandes e títulos'),
        for (final (name, style) in slots)
          if (_isDisplay(style)) specimen(name, style),
        _Specimen(
          label: 'MoneyText display · ${_metrics(AppTypography.displayLarge)}',
          child: const MoneyText('R\$ 4.196,51', size: MoneySize.display),
        ),
        _Specimen(
          label: 'appBarTitle · ${_metrics(AppTypography.appBarTitle)}',
          child: Text(
            'Extrato',
            style: AppTypography.appBarTitle.copyWith(color: onSurface),
          ),
        ),
        _Specimen(
          label: 'moneyInput · ${_metrics(AppTypography.moneyInput)}',
          child: Text(
            '1.234,56',
            style: AppTypography.moneyInput.copyWith(color: onSurface),
          ),
        ),
        const _Subheading('Dígitos tabulares (tnum)'),
        AppPanel(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.panel,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              for (final (label, value) in const [
                ('Mercado', 'R\$ 1.111,11'),
                ('Aluguel', 'R\$ 8.888,88'),
                ('Salário', 'R\$ 4.196,51'),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: t.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      MoneyText(value),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Specimen extends StatelessWidget {
  const _Specimen({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: _mono(context)),
          const Gap.xxs(),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Radii

class _Radii extends StatelessWidget {
  const _Radii();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final tint = primary.withValues(alpha: context.effects.tintAlpha);
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final (name, radius) in const [
          ('sm', AppRadius.sm),
          ('md', AppRadius.md),
          ('lg', AppRadius.lg),
          ('xl', AppRadius.xl),
          ('pill', AppRadius.pill),
        ])
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: primary, width: 1.5),
                ),
                child: SizedBox(
                  width: radius == AppRadius.pill ? 72 : 48,
                  height: 48,
                ),
              ),
              const Gap(6),
              Text('$name ${_number(radius)}', style: _mono(context)),
            ],
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Spacing

class _Spacing extends StatelessWidget {
  const _Spacing();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final mono = _mono(context);
    return Column(
      children: [
        for (final (name, value) in const [
          ('xs', AppSpacing.xs),
          ('sm', AppSpacing.sm),
          ('md', AppSpacing.md),
          ('lg', AppSpacing.lg),
          ('xl', AppSpacing.xl),
          ('xxl', AppSpacing.xxl),
          ('screen', AppSpacing.screen),
          ('panel', AppSpacing.panel),
          ('hero', AppSpacing.hero),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(width: 64, child: Text(name, style: mono)),
                SizedBox(
                  width: value * 4,
                  height: 12,
                  child: ColoredBox(color: primary),
                ),
                const Gap.sm(),
                Text('${_number(value)} pt', style: mono),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 9. Motion

class _Motion extends StatelessWidget {
  const _Motion();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = _mono(context);
    final durations = <(String, Duration, String)>[
      ('fast', AppDurations.fast, 'Pressão do CTA e do FAB, ícone da senha.'),
      (
        'normal',
        AppDurations.normal,
        'Estado do CTA, força da senha, entrada do StateView.',
      ),
      ('slow', AppDurations.slow, 'Entrada do BalanceCard e do AppFab.'),
      (
        'emphasized',
        AppDurations.emphasized,
        'Preenchimento da CategoryBar (o mais longo).',
      ),
    ];
    final curves = <(String, Curve, String)>[
      (
        'standard · easeOutCubic',
        AppCurves.standard,
        'Entradas e mudanças de estado.',
      ),
      (
        'playful · easeOutBack',
        AppCurves.playful,
        'Só escala (AppFab), nunca em números.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPanel(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              for (final (index, (name, duration, usage))
                  in durations.indexed) ...[
                if (index > 0) const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          Text(
                            '${duration.inMilliseconds} ms',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontFeatures: AppTypography.tabularFigures,
                            ),
                          ),
                        ],
                      ),
                      const Gap.xxs(),
                      Text(usage, style: mono),
                    ],
                  ),
                ),
              ],
              for (final (name, curve, usage) in curves) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      _CurvePlot(curve: curve),
                      const Gap.md(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: theme.textTheme.titleSmall),
                            const Gap.xxs(),
                            Text(usage, style: mono),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap.md(),
        Text(
          'AppMotion.of zera as durações quando o sistema pede menos '
          'movimento. Nada fica em loop e nada passa de 600 ms.',
          style: mono,
        ),
      ],
    );
  }
}

/// 56x36 plot of a curve (with room for easeOutBack's overshoot).
class _CurvePlot extends StatelessWidget {
  const _CurvePlot({required this.curve});

  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 56,
      height: 36,
      child: CustomPaint(
        painter: _CurvePainter(
          curve: curve,
          line: scheme.primary,
          axis: scheme.outlineVariant,
        ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  const _CurvePainter({
    required this.curve,
    required this.line,
    required this.axis,
  });

  final Curve curve;
  final Color line;
  final Color axis;

  @override
  void paint(Canvas canvas, Size size) {
    // 0 sits 4px above the bottom; 1 sits 8px below the top, so an
    // overshoot of about 10% still fits.
    double y(double v) => (size.height - 4) - v * (size.height - 12);

    final axisPaint = Paint()
      ..color = axis
      ..strokeWidth = 1;
    canvas
      ..drawLine(Offset(0, y(0)), Offset(size.width, y(0)), axisPaint)
      ..drawLine(Offset(0, y(1)), Offset(size.width, y(1)), axisPaint);

    final path = Path()..moveTo(0, y(0));
    for (var i = 1; i <= 40; i++) {
      final t = i / 40;
      path.lineTo(t * size.width, y(curve.transform(t)));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CurvePainter oldDelegate) =>
      oldDelegate.curve != curve ||
      oldDelegate.line != line ||
      oldDelegate.axis != axis;
}
