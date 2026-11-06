import 'package:flutter/material.dart';

import '../theme/app_effects.dart';
import '../theme/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'gap.dart';

/// Label on the left, value on the right: one line of a detail screen.
///
/// Screens place rows in an `AppPanel(padding: h16 v4)` separated by
/// `Divider(indent: 48)`, which lines up with the text after the icon tile.
class DetailRow extends StatelessWidget {
  const DetailRow({
    required this.label,
    required this.value,
    super.key,
    this.icon,
  });

  final String label;

  /// Already formatted. Long values wrap instead of being cut.
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              // Primary tint squircle.
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(
                    alpha: context.effects.tintAlpha,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox.square(
                  dimension: 36,
                  child: Icon(icon, size: 18, color: scheme.primary),
                ),
              ),
              const Gap.md(),
            ],
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.semanticColors.muted,
              ),
            ),
            const Gap.lg(),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                // Tabular digits so amounts and dates line up across rows.
                style: AppTypography.weighted(AppTypography.titleSmall, 600)
                    .copyWith(
                      color: scheme.onSurface,
                      fontFeatures: AppTypography.tabularFigures,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
