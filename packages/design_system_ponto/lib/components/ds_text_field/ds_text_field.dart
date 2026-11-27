import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

/// Campo de texto com rótulo acima, dica, ajuda e mensagem de erro opcional.
class DsTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? icon;
  final String? prefixText;
  final Widget? suffix;
  final bool obscureText;
  final bool pill;

  /// Campo só de exibição que reage ao toque (ex.: abre um seletor de data).
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final TextStyle? style;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const DsTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.helperText,
    this.icon,
    this.prefixText,
    this.suffix,
    this.obscureText = false,
    this.pill = false,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.style,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final radius = BorderRadius.circular(pill ? DsRadius.pill : DsRadius.md);
    OutlineInputBorder border(BorderSide side) => OutlineInputBorder(borderRadius: radius, borderSide: side);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DsTypography.label.copyWith(color: c.textPrimary)),
        const SizedBox(height: DsSpacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DsSizes.inputHeight),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: obscureText ? 1 : maxLines,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: style ?? DsTypography.body.copyWith(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: (style ?? DsTypography.body).copyWith(color: c.textSecondary),
              // O prefixo de texto vai como "ícone" para ficar sempre visível,
              // e não só com o campo em foco.
              prefixIcon: prefixText != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: DsSpacing.md, right: DsSpacing.xs),
                      child: Text(
                        prefixText!.trim(),
                        style: (style ?? DsTypography.body).copyWith(color: c.textSecondary),
                      ),
                    )
                  : icon == null
                      ? null
                      : Icon(icon, size: DsSizes.iconMd, color: c.textSecondary),
              prefixIconConstraints: prefixText != null ? const BoxConstraints(minWidth: 0, minHeight: 0) : null,
              suffixIcon: suffix,
              errorText: errorText,
              helperText: helperText,
              border: border(BorderSide.none),
              enabledBorder: border(BorderSide.none),
              focusedBorder: border(BorderSide(color: c.accent, width: 2)),
              errorBorder: border(BorderSide(color: c.danger, width: 1.5)),
              focusedErrorBorder: border(BorderSide(color: c.danger, width: 2)),
            ),
          ),
        ),
      ],
    );
  }
}
