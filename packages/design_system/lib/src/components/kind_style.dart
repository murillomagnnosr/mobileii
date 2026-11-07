import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import 'money_text.dart';
import 'transaction_tile.dart';

/// Visual identity of a [TransactionKind]: solid color, container tint,
/// arrow icon and money tone.
typedef KindStyle = ({
  Color color,
  Color container,
  IconData icon,
  MoneyTone tone,
});

/// The single kind mapping used by TransactionTile, KindOrb, BalanceCard
/// legs, TransactionKindSelector and the Detalhe header.
///
/// The icons are part of the contract: down means money coming into the
/// wallet, up means money leaving it. Kinds never differ by color alone.
KindStyle kindStyleOf(BuildContext context, TransactionKind kind) {
  final s = context.semanticColors;
  return switch (kind) {
    TransactionKind.income => (
      color: s.income,
      container: s.incomeContainer,
      icon: Icons.arrow_downward_rounded,
      tone: MoneyTone.income,
    ),
    TransactionKind.expense => (
      color: s.expense,
      container: s.expenseContainer,
      icon: Icons.arrow_upward_rounded,
      tone: MoneyTone.expense,
    ),
    TransactionKind.transfer => (
      color: s.transfer,
      container: s.transferContainer,
      icon: Icons.swap_horiz_rounded,
      tone: MoneyTone.neutral,
    ),
  };
}

/// Squircle (or circle) with the kind arrow on a same-hue tonal gradient.
///
/// The tonal fill (container toward surface) is in the gradient budget; it
/// never takes the brand gradient. No glow.
class KindOrb extends StatelessWidget {
  /// Creates an orb for [kind], 44px by default.
  const KindOrb({
    required this.kind,
    super.key,
    this.size = 44,
    this.circle = false,
  });

  /// Kind whose colors and arrow are shown (from [kindStyleOf]).
  final TransactionKind kind;

  /// Outer side: 44 in list tiles, 24 in the hero legs, 52 in Detalhe.
  final double size;

  /// Circle instead of a squircle (hero legs).
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final style = kindStyleOf(context, kind);
    final surface = Theme.of(context).colorScheme.surface;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        // 44 -> 14, 52 -> 16.
        borderRadius: circle
            ? null
            : BorderRadius.circular(
                size >= 52 ? 16 : (size * 0.32).roundToDouble(),
              ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.container, Color.lerp(style.container, surface, 0.5)!],
        ),
        // Decorative: the icon carries the information.
        border: Border.all(color: style.color.withValues(alpha: 0.24)),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: Icon(style.icon, size: size * 0.5, color: style.color),
        ),
      ),
    );
  }
}
