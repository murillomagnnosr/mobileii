import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_button_view_model.dart';

class DsButtonComponent extends StatelessWidget {
  final DsButtonViewModel viewModel;
  final VoidCallback? onPressed;

  const DsButtonComponent({super.key, required this.viewModel, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final enabled = onPressed != null && !viewModel.isLoading;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.pill));

    final tone = viewModel.destructive ? c.danger : c.accent;
    final onTone = viewModel.destructive ? Colors.white : c.textOnAccent;

    final (Color bg, Color fg, BorderSide? side) = switch (viewModel.variant) {
      DsButtonVariant.primary => (tone, onTone, null),
      DsButtonVariant.secondary => (Colors.transparent, tone, BorderSide(color: tone, width: 1.5)),
      DsButtonVariant.ghost => (Colors.transparent, tone, null),
    };

    final button = switch (viewModel.variant) {
      DsButtonVariant.primary => FilledButton(
          onPressed: enabled ? onPressed : null,
          style: _style(bg, fg, side, shape, c.disabled, c.disabledText),
          child: _content(fg),
        ),
      _ => OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: _style(bg, fg, side, shape, Colors.transparent, c.disabledText),
          child: _content(fg),
        ),
    };

    return SizedBox(
      width: viewModel.expanded ? double.infinity : null,
      height: DsSizes.buttonHeight,
      child: button,
    );
  }

  ButtonStyle _style(Color bg, Color fg, BorderSide? side, OutlinedBorder shape, Color disabledBg, Color disabledFg) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: const WidgetStatePropertyAll(Size(0, DsSizes.buttonHeight)),
      backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled) ? disabledBg : bg),
      foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled) ? disabledFg : fg),
      side: WidgetStatePropertyAll(side ?? BorderSide.none),
      shape: WidgetStatePropertyAll(shape),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: DsSpacing.lg)),
      textStyle: WidgetStatePropertyAll(DsTypography.label),
    );
  }

  Widget _content(Color color) {
    if (viewModel.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
      );
    }
    final text = Text(viewModel.label);
    if (viewModel.icon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(viewModel.icon, size: DsSizes.iconMd),
        const SizedBox(width: DsSpacing.xs),
        text,
      ],
    );
  }
}
