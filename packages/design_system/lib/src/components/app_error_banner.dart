import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_typography.dart';
import 'gap.dart';

/// Inline error message on a solid expense tint, announced to screen
/// readers as a live region.
///
/// Used for the login error, the form error and the Detalhe action error.
/// [textKey] goes on the inner [Text], so `find.text` and key lookups keep
/// working.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner(this.message, {super.key, this.textKey});

  final String message;

  /// Key of the message [Text].
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Same as scheme.errorContainer.
          color: context.semanticColors.expenseContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded, size: 18, color: error),
              const Gap(8),
              Expanded(
                child: Text(
                  message,
                  key: textKey,
                  style: AppTypography.weighted(
                    theme.textTheme.bodyMedium!,
                    600,
                  ).copyWith(color: error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
