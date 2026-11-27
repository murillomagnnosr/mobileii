import 'package:flutter/material.dart';

import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

/// Indicador compacto de estado. `tone` vem dos papéis semânticos (success, warning, danger...).
class DsStatusPill extends StatelessWidget {
  final String label;
  final Color tone;
  final IconData? icon;

  const DsStatusPill({super.key, required this.label, required this.tone, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.xs + 2, vertical: DsSpacing.xxs + 2),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(DsRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: DsSizes.iconSm, color: tone),
            const SizedBox(width: DsSpacing.xxs),
          ],
          Text(label, style: DsTypography.caption.copyWith(color: tone)),
        ],
      ),
    );
  }
}
