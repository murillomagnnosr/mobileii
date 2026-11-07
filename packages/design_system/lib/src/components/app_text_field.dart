import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Every border slot of an [InputDecoration].
typedef _FieldBorders = ({
  InputBorder border,
  InputBorder? enabled,
  InputBorder? focused,
  InputBorder? error,
  InputBorder? focusedError,
  InputBorder? disabled,
});

/// Text input of the design system: single-line by default, multi-line
/// (e.g. the Observação field) through [maxLines].
///
/// A thin layer over [TextField] that fixes the decoration and exposes only
/// what the app screens need. Validation happens outside: pass the message
/// through [errorText]. Borders, fill, label and icon colors come from the
/// theme's input decoration (outline at rest, primary on focus, error).
class AppTextField extends StatelessWidget {
  /// Creates a field labelled [label].
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.hint,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.style,
    this.prefixText,
    this.pill = false,
    this.floatingLabelBehavior,
  });

  /// Floating label, also announced by screen readers.
  final String label;

  /// Text controller. Null lets the [TextField] keep its own.
  final TextEditingController? controller;

  /// Placeholder shown while the field is empty and its label floats.
  final String? hint;

  /// Validation message. Non-null paints the error border and text.
  final String? errorText;

  /// Muted line under the field, replaced by [errorText] when present.
  final String? helperText;

  /// Keyboard to open, e.g. [TextInputType.emailAddress].
  final TextInputType? keyboardType;

  /// Action key of the keyboard (next, done).
  final TextInputAction? textInputAction;

  /// Automatic capitalization. Defaults to none.
  final TextCapitalization textCapitalization;

  /// Hides the typed text. `PasswordField` manages this itself.
  final bool obscureText;

  /// False greys the field out and ignores input.
  final bool enabled;

  /// Requests focus on the first build.
  final bool autofocus;

  /// Visible lines. Above 1 the label always floats and [prefixIcon] lines
  /// up with the first line of text.
  final int maxLines;

  /// Leading icon at 22px, tinted by state (rest, focus, error).
  final IconData? prefixIcon;

  /// Trailing widget, e.g. the `PasswordField` visibility toggle.
  final Widget? suffix;

  /// Formatters applied while typing (digits only, money masks).
  final List<TextInputFormatter>? inputFormatters;

  /// Autofill hints, e.g. [AutofillHints.email].
  final Iterable<String>? autofillHints;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the keyboard action key is pressed.
  final ValueChanged<String>? onSubmitted;

  /// External focus node, to move focus between fields.
  final FocusNode? focusNode;

  /// Style of the typed text (e.g. `AppTypography.moneyInput` for Valor).
  ///
  /// When set, the hint uses the same style in the muted color, and the
  /// [prefixText] renders at 72% of its size, weight 600.
  final TextStyle? style;

  /// Fixed text before the input, such as `'R$ '`.
  final String? prefixText;

  /// Fully rounded borders and roomier padding (search field). The border
  /// sides still come from the theme, so focus and error look the same.
  final bool pill;

  /// Defaults to [FloatingLabelBehavior.always] when [prefixText] is set
  /// (Flutter hides the prefix and the hint while the label rests inside the
  /// field, so an empty Valor would show neither 'R$' nor '0,00') and on
  /// multi-line fields.
  final FloatingLabelBehavior? floatingLabelBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // onSurfaceVariant is the palette's onSurfaceMuted.
    final muted = theme.colorScheme.onSurfaceVariant;
    final borders = pill ? _borders(theme, AppRadius.pillAll) : null;

    final style = this.style;
    TextStyle? hintStyle;
    TextStyle? prefixStyle;
    if (style != null) {
      hintStyle = style.copyWith(color: muted);
      // TextField fills unset fields from bodyLarge.
      final fontSize =
          style.fontSize ?? theme.textTheme.bodyLarge?.fontSize ?? 16;
      prefixStyle = AppTypography.weighted(
        style.copyWith(fontSize: fontSize * 0.72, color: muted),
        600,
      );
    }

    // InputDecorator centres the prefix icon in the whole box. On a
    // multi-line field, bottom padding of (maxLines - 1) lines lifts it by
    // half that, onto the first line of text.
    Widget? icon;
    if (prefixIcon != null) {
      icon = Icon(prefixIcon, size: 22);
      if (maxLines > 1) {
        final line = style ?? theme.textTheme.bodyLarge;
        final lineHeight = (line?.fontSize ?? 16) * (line?.height ?? 1.0);
        icon = Padding(
          padding: EdgeInsets.only(bottom: (maxLines - 1) * lineHeight),
          child: icon,
        );
      }
    }

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: style,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: hintStyle,
        errorText: errorText,
        helperText: helperText,
        prefixText: prefixText,
        prefixStyle: prefixStyle,
        prefixIcon: icon,
        suffixIcon: suffix,
        // A multi-line field floats its label too: resting, it would sit in
        // the middle of the tall box, away from the first-line icon.
        // (alignLabelWithHint would also shift the floated label off the
        // column every other field uses.)
        floatingLabelBehavior:
            floatingLabelBehavior ??
            (prefixText != null || maxLines > 1
                ? FloatingLabelBehavior.always
                : null),
        contentPadding: pill
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
            : null,
        border: borders?.border,
        enabledBorder: borders?.enabled,
        focusedBorder: borders?.focused,
        errorBorder: borders?.error,
        focusedErrorBorder: borders?.focusedError,
        disabledBorder: borders?.disabled,
      ),
    );
  }

  /// Rebuilds every border of the theme with [radius], keeping the theme's
  /// sides, so the pill variant still follows rest, focus, error and
  /// disabled states.
  static _FieldBorders _borders(ThemeData theme, BorderRadius radius) {
    final t = theme.inputDecorationTheme;
    InputBorder? round(InputBorder? b) => switch (b) {
      final OutlineInputBorder o => o.copyWith(borderRadius: radius),
      final InputBorder o => OutlineInputBorder(
        borderRadius: radius,
        borderSide: o.borderSide,
      ),
      null => null,
    };
    return (
      border: round(t.border) ?? OutlineInputBorder(borderRadius: radius),
      enabled: round(t.enabledBorder),
      focused: round(t.focusedBorder),
      error: round(t.errorBorder),
      focusedError: round(t.focusedErrorBorder),
      disabled: round(t.disabledBorder),
    );
  }
}
