import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

/// Linha "ícone + rótulo + valor" usada em telas de detalhe.
class DsDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const DsDetailRow({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DsSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: DsSizes.iconMd, color: c.accent),
          const SizedBox(width: DsSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DsTypography.caption.copyWith(color: c.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: DsTypography.body.copyWith(color: c.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
