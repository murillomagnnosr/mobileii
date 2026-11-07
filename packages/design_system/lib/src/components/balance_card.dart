import 'package:flutter/material.dart';

import '../theme/app_effects.dart';
import '../theme/app_semantic_colors.dart';
import '../tokens/app_durations.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'gap.dart';
import 'kind_style.dart';
import 'money_text.dart';
import 'transaction_tile.dart';

/// Summary card at the top of the home screen: balance of the month with
/// income and expense underneath.
///
/// A "nebula" card: violet-to-ocean gradient with an iridescent rim, a cyan
/// blob and two faint orbit rings. The balance is solid [AppEffects.onHero]
/// on the nebula; the legs sit on near-opaque chips so the kind colors keep
/// their contrast.
class BalanceCard extends StatelessWidget {
  /// Creates the card from already formatted figures.
  const BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
    super.key,
    this.title = 'Saldo do mês',
    this.monthLabel,
    this.animateIn = true,
  });

  /// Balance of the month, already formatted ("R\$ 4.196,51"). Shown as a
  /// display [MoneyText] that scales down instead of being cut.
  final String balance;

  /// Income of the month, already formatted. Shown on the "Entradas" leg.
  final String income;

  /// Expense of the month, already formatted. Shown on the "Saídas" leg.
  final String expense;

  /// Muted label above the balance.
  final String title;

  /// E.g. "Setembro 2026". Shown verbatim on the spark pill, which counts
  /// as one of the two spark spots of the screen.
  final String? monthLabel;

  /// Fades and slides the card in once per mount.
  final bool animateIn;

  @override
  Widget build(BuildContext context) {
    final e = context.effects;
    return _Entrance(
      enabled: animateIn,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.xlAll,
          gradient: e.heroRim,
          boxShadow: e.heroShadow,
        ),
        // The 1.5px left uncovered by the fill is the iridescent rim.
        child: Padding(
          padding: const EdgeInsets.all(1.5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26.5),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: e.heroGradient),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: e.wash(
                        e.heroBlob,
                        center: const Alignment(0.9, -1.0),
                        radius: 0.8,
                      ),
                    ),
                  ),
                ),
                // Orbit rings, concentric, bottom-left.
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
                // Non-positioned: sizes the Stack.
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.hero),
                  child: _content(context, e),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, AppEffects e) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final monthLabel = this.monthLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.weighted(
                  text.bodyMedium!,
                  600,
                ).copyWith(color: e.onHeroMuted),
              ),
            ),
            // Spark spot: a fill only, never a money cue.
            if (monthLabel != null)
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: e.spark,
                  shape: const StadiumBorder(),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    monthLabel,
                    style: text.labelMedium!.copyWith(color: e.onSpark),
                  ),
                ),
              ),
          ],
        ),
        const Gap.sm(),
        // The onHero override wraps ONLY the balance figure.
        Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(onSurface: e.onHero),
          ),
          child: MoneyText(balance, size: MoneySize.display),
        ),
        const Gap(20),
        Row(
          children: [
            Expanded(
              child: _Leg(
                kind: TransactionKind.income,
                label: 'Entradas',
                value: income,
              ),
            ),
            const Gap.md(),
            Expanded(
              child: _Leg(
                kind: TransactionKind.expense,
                label: 'Saídas',
                value: expense,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Fade and slide-up played once per mount; skipped with reduced motion.
class _Entrance extends StatelessWidget {
  const _Entrance({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppMotion.of(context, AppDurations.slow),
      curve: AppCurves.standard,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

/// Faint decorative ring on the nebula.
class _Orbit extends StatelessWidget {
  const _Orbit({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
      ),
    );
  }
}

/// Income or expense chip under the balance. The arrow and the money tone
/// come from [kindStyleOf], so kinds never differ by color alone.
class _Leg extends StatelessWidget {
  const _Leg({required this.kind, required this.label, required this.value});

  final TransactionKind kind;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final e = context.effects;
    final style = kindStyleOf(context, kind);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: e.legChip,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: e.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                KindOrb(kind: kind, size: 24, circle: true),
                const Gap.sm(),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall!
                        .copyWith(color: context.semanticColors.muted),
                  ),
                ),
              ],
            ),
            const Gap(6),
            // Scales down on narrow phones instead of being cut.
            MoneyText(
              value,
              tone: style.tone,
              size: MoneySize.medium,
              scaleDown: true,
            ),
          ],
        ),
      ),
    );
  }
}
