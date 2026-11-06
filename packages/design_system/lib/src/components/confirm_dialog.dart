import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';

/// Asks the user to confirm an action. Resolves to `true` only when the
/// confirm button is tapped; dismissing the dialog counts as `false`.
///
/// [destructive] paints the confirm button and the icon circle with the
/// error color, for deletes. [icon] defaults to a trash can when
/// [destructive] and to a question mark otherwise.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  bool destructive = false,
  IconData? icon,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      icon: icon,
    ),
  );
  return confirmed ?? false;
}

/// The dialog shown by [showConfirmDialog]. Public so the gallery and the
/// tests can render it directly.
///
/// Shape, colors and barrier come from the dialog theme. The confirm button
/// is a solid [FilledButton] (the global theme is never a gradient).
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    super.key,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.destructive = false,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  /// Glyph in the circle above the title. `null` picks the default.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: _IconCircle(
        icon:
            icon ??
            (destructive
                ? Icons.delete_outline_rounded
                : Icons.help_outline_rounded),
        destructive: destructive,
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
          child: Text(cancelLabel),
        ),
        FilledButton(
          key: const Key('confirm_dialog_confirm'),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  minimumSize: const Size(96, 44),
                  shape: const StadiumBorder(),
                )
              : FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

/// 48px tinted circle with the dialog glyph.
class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.destructive});

  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: destructive
            ? semantic.expenseContainer
            : scheme.primaryContainer,
      ),
      child: SizedBox.square(
        dimension: 48,
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: destructive ? scheme.error : scheme.primary,
          ),
        ),
      ),
    );
  }
}
