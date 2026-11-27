import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import '../ds_button/ds_button_factory.dart';

/// Título de seção com ação opcional à direita ("Ver todos").
class DsSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DsSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return Padding(
      padding: const EdgeInsets.only(top: DsSpacing.lg, bottom: DsSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(title, style: DsTypography.subtitle.copyWith(color: c.textPrimary))),
          if (actionLabel != null && onAction != null)
            DsButtonFactory.ghost(label: actionLabel!, onPressed: onAction),
        ],
      ),
    );
  }
}
