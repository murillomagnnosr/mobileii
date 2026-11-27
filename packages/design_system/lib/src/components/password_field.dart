import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_durations.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';
import 'app_text_field.dart';
import 'gap.dart';

/// Password strength as computed by [PasswordField.strengthOf].
enum PasswordStrength {
  /// No text yet: empty bar, no label.
  empty,

  /// Score up to 2: "Fraca", expense color, a third of the bar.
  weak,

  /// Score 3 or 4: "Razoável", warning color, two thirds of the bar.
  fair,

  /// Score 5 or more: "Forte", income color, full bar.
  strong,
}

/// Password input with a show/hide toggle and an optional strength bar.
///
/// Stateful on purpose: whether the text is hidden is UI state that belongs
/// to the widget, not to the screen's ViewModel.
class PasswordField extends StatefulWidget {
  /// Creates a password field, hidden until the eye toggle is tapped.
  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Senha',
    this.errorText,
    this.showStrength = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.focusNode,
    this.enabled = true,
  });

  /// Text controller. Null makes the field create and dispose its own.
  final TextEditingController? controller;

  /// Floating label. Defaults to 'Senha'.
  final String label;

  /// Validation message under the field.
  final String? errorText;

  /// Show a strength meter under the field.
  final bool showStrength;

  /// Action key of the keyboard (next, done).
  final TextInputAction? textInputAction;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the keyboard action key is pressed.
  final ValueChanged<String>? onSubmitted;

  /// Autofill hints, e.g. [AutofillHints.password].
  final Iterable<String>? autofillHints;

  /// External focus node, to move focus between fields.
  final FocusNode? focusNode;

  /// False greys the field out and ignores input.
  final bool enabled;

  /// Score: one point per character class (lower, upper, digit, symbol),
  /// plus one at 8 characters and one more at 12.
  static PasswordStrength strengthOf(String value) {
    if (value.isEmpty) return PasswordStrength.empty;
    var classes = 0;
    if (value.contains(RegExp('[a-z]'))) classes++;
    if (value.contains(RegExp('[A-Z]'))) classes++;
    if (value.contains(RegExp('[0-9]'))) classes++;
    if (value.contains(RegExp(r'[^A-Za-z0-9]'))) classes++;
    final score =
        classes + (value.length >= 8 ? 1 : 0) + (value.length >= 12 ? 1 : 0);
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    return PasswordStrength.strong;
  }

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;
  late TextEditingController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(PasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onTextChanged);
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.showStrength) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final field = AppTextField(
      label: widget.label,
      controller: _controller,
      errorText: widget.errorText,
      obscureText: _obscure,
      enabled: widget.enabled,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      prefixIcon: Icons.lock_outline_rounded,
      suffix: IconButton(
        key: const Key('password_toggle'),
        tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
        icon: AnimatedSwitcher(
          duration: AppMotion.of(context, AppDurations.fast),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_rounded,
            key: ValueKey(_obscure),
            // Primary while the password is visible, as a reminder.
            color: _obscure ? scheme.onSurfaceVariant : scheme.primary,
          ),
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );

    if (!widget.showStrength) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        const Gap.sm(),
        _StrengthBar(strength: PasswordField.strengthOf(_controller.text)),
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final scheme = Theme.of(context).colorScheme;
    final (fill, color, label) = switch (strength) {
      PasswordStrength.empty => (0.0, scheme.outline, ''),
      PasswordStrength.weak => (1 / 3, semantic.expense, 'Fraca'),
      PasswordStrength.fair => (2 / 3, semantic.warning, 'Razoável'),
      PasswordStrength.strong => (1.0, semantic.income, 'Forte'),
    };
    return Semantics(
      label: label.isEmpty ? 'Força da senha' : 'Força da senha: $label',
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.pillAll,
              // End-only tween: the first build starts at the value, later
              // changes glide. The label below switches immediately.
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: fill),
                duration: AppMotion.of(context, AppDurations.normal),
                curve: AppCurves.standard,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  color: color,
                  // surfaceContainerHighest is the palette's surfaceVariant.
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
          const Gap.sm(),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTypography.weighted(
                AppTypography.bodySmall,
                700,
              ).copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
