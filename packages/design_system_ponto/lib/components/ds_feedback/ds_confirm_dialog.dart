import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import '../ds_button/ds_button_factory.dart';

/// Diálogo de confirmação. Devolve `true` só quando a pessoa confirma.
Future<bool> showDsConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancelar',
  IconData? icon,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final c = context.ds;
      final tone = destructive ? c.danger : c.accent;
      return Dialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.lg)),
        child: Padding(
          padding: const EdgeInsets.all(DsSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null || destructive) ...[
                Icon(icon ?? Icons.delete_outline_rounded, color: tone, size: 28),
                const SizedBox(height: DsSpacing.sm),
              ],
              Text(title, style: DsTypography.title.copyWith(color: c.textPrimary)),
              const SizedBox(height: DsSpacing.xs),
              Text(message, style: DsTypography.body.copyWith(color: c.textSecondary)),
              const SizedBox(height: DsSpacing.lg),
              DsButtonFactory.primary(
                key: const Key('confirm_dialog_confirm'),
                label: confirmLabel,
                destructive: destructive,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: DsSpacing.xs),
              DsButtonFactory.secondary(label: cancelLabel, onPressed: () => Navigator.of(context).pop(false)),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
