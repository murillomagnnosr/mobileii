import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import 'gap.dart';

/// Small uppercase label that opens a group of items, with an optional
/// action pill on the right ("Ver todos").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Solid accent dot: decorative, no gradient or glow.
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.secondary,
                  ),
                ),
                const Gap.sm(),
                Flexible(
                  child: Text(
                    title.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: context.semanticColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            // A Material (not a Container), so the InkWell ripple shows on
            // the pill. 36px tall: above the WCAG 2.5.8 minimum of 24.
            Semantics(
              button: true,
              child: Material(
                color: scheme.primaryContainer,
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onAction,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 36),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            actionLabel!,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                          const Gap.xs(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: scheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
