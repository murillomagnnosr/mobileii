import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_durations.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';
import 'gap.dart';

/// One row of a "by category" summary: label, amount, percentage and a bar
/// proportional to [share].
///
/// [amount] arrives formatted, like everywhere else in the package; the
/// widget does not know what a category or a transaction is.
class CategoryBar extends StatelessWidget {
  const CategoryBar({
    required this.label,
    required this.amount,
    required this.share,
    super.key,
  });

  final String label;

  /// Already formatted, e.g. "R\$ 702,20".
  final String amount;

  /// Fraction of the total, from 0 to 1. Values outside are clamped.
  final double share;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final muted = context.semanticColors.muted;
    final fraction = share.clamp(0.0, 1.0).toDouble();
    final percent = '${(fraction * 100).round()}%';
    return Semantics(
      label: '$label, $amount, $percent',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.weighted(text.bodyMedium!, 600),
                  ),
                ),
                const Gap.md(),
                Text(
                  amount,
                  style: AppTypography.weighted(
                    text.bodyMedium!,
                    700,
                  ).copyWith(fontFeatures: AppTypography.tabularFigures),
                ),
                const Gap.md(),
                SizedBox(
                  width: 44,
                  child: Text(
                    percent,
                    textAlign: TextAlign.end,
                    style: text.bodySmall!.copyWith(
                      color: muted,
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(6),
            ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: SizedBox(
                height: 8,
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  // widthFactor is the final share from the first frame;
                  // the grow-in is a horizontal scale inside it. Never
                  // animate widthFactor itself.
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: AppMotion.of(context, AppDurations.emphasized),
                      curve: AppCurves.standard,
                      // Solid primary: no gradient, no glow.
                      child: ColoredBox(color: theme.colorScheme.primary),
                      builder: (context, t, child) => Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.diagonal3Values(t, 1, 1),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
