import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

/// Faixa de erro de formulário ou ação.
class DsErrorBanner extends StatelessWidget {
  final String message;
  final Key? textKey;

  const DsErrorBanner(this.message, {super.key, this.textKey});

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return Container(
      padding: const EdgeInsets.all(DsSpacing.sm),
      decoration: BoxDecoration(
        color: c.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DsRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: DsSizes.iconMd, color: c.danger),
          const SizedBox(width: DsSpacing.xs),
          Expanded(child: Text(message, key: textKey, style: DsTypography.bodySmall.copyWith(color: c.danger))),
        ],
      ),
    );
  }
}
