import 'package:flutter/material.dart';

import '../theme/app_effects.dart';
import '../tokens/app_durations.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'gap.dart';

/// Visual weight of an [AppButton].
enum AppButtonVariant {
  /// Neon CTA pill: gradient plus glow (counts in both budgets).
  primary,

  /// Outlined pill for alternative and destructive actions.
  secondary,

  /// Text only, for low-emphasis actions.
  text,
}

/// Button of the design system.
///
/// - primary: the neon CTA pill. A violet-to-cyan gradient with a coloured
///   glow, painted OUTSIDE a transparent [FilledButton] so the button's own
///   ink and overlay stay visible on top of it.
/// - secondary: an [OutlinedButton] from the theme (56px stadium, 1.5px
///   outline), error-coloured when [destructive].
/// - text: a [TextButton] from the theme.
///
/// While [isLoading] is true the button shows a spinner and ignores taps, so
/// a ViewModel can bind it straight to a running command.
class AppButton extends StatelessWidget {
  /// Creates a button; [variant] defaults to the primary CTA.
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
    this.destructive = false,
  });

  /// Outlined button; [destructive] paints it in the error hue.
  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
    this.destructive = false,
  }) : variant = AppButtonVariant.secondary;

  /// Text button, shrink-wrapped by default and never destructive.
  const AppButton.text({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.expanded = false,
  }) : variant = AppButtonVariant.text,
       destructive = false;

  /// Button text and semantics label (still announced while loading).
  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// Which of the three looks is painted.
  final AppButtonVariant variant;

  /// Swaps the label for a spinner and ignores taps.
  final bool isLoading;

  /// Optional 20px icon before [label].
  final IconData? icon;

  /// Stretch to the parent's width. Text buttons default to false.
  final bool expanded;

  /// Paints the secondary variant in the error hue (Excluir, Sair).
  /// Ignored by the primary and text variants.
  final bool destructive;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final child = _Content(label: label, icon: icon, isLoading: isLoading);
    final callback = _enabled ? onPressed : null;
    final scheme = Theme.of(context).colorScheme;

    final Widget button = switch (variant) {
      AppButtonVariant.primary => _primary(context, scheme, callback, child),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        style: _secondaryStyle(scheme),
        child: child,
      ),
      AppButtonVariant.text => TextButton(onPressed: callback, child: child),
    };

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: SizedBox(width: expanded ? double.infinity : null, child: button),
    );
  }

  Widget _primary(
    BuildContext context,
    ColorScheme scheme,
    VoidCallback? callback,
    Widget child,
  ) {
    final e = context.effects;
    return _PressScale(
      enabled: _enabled,
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppDurations.normal),
        decoration: _primaryDecoration(scheme, e),
        child: FilledButton(
          onPressed: callback,
          style: _primaryStyle(scheme, e),
          child: child,
        ),
      ),
    );
  }

  /// Gradient + glow when enabled, a dimmed gradient while loading and a
  /// flat track colour when disabled. AnimatedContainer cross-fades them.
  BoxDecoration _primaryDecoration(ColorScheme scheme, AppEffects e) {
    if (isLoading) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: e.ctaGradient.colors
              .map((c) => c.withValues(alpha: 0.85))
              .toList(),
        ),
        borderRadius: AppRadius.pillAll,
      );
    }
    if (onPressed == null) {
      return BoxDecoration(
        color: scheme.surfaceContainerHighest, // surfaceVariant
        borderRadius: AppRadius.pillAll,
      );
    }
    return BoxDecoration(
      gradient: e.ctaGradient,
      borderRadius: AppRadius.pillAll,
      boxShadow: e.ctaGlow,
    );
  }

  /// Transparent FilledButton: the fill comes from the ancestor decoration.
  /// The global FilledButton theme stays solid for dialogs.
  ButtonStyle _primaryStyle(ColorScheme scheme, AppEffects e) {
    return FilledButton.styleFrom(
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      foregroundColor: e.onGradient,
      // The button is disabled while loading; keep the spinner on-gradient.
      disabledForegroundColor: isLoading
          ? e.onGradient
          : scheme.onSurfaceVariant,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      minimumSize: const Size(64, 56),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      textStyle: AppTypography.labelLarge,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return e.onGradient.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return e.onGradient.withValues(alpha: 0.08);
        }
        return null;
      }),
    );
  }

  /// The theme's 1.5px outline applies in every state, so the disabled side
  /// is set here to the M3 default (onSurface at 12%). Destructive swaps the
  /// label, side and overlay to the error hue; disabled stays neutral.
  ButtonStyle _secondaryStyle(ColorScheme scheme) {
    final disabledSide = BorderSide(
      color: scheme.onSurface.withValues(alpha: 0.12),
      width: 1.5,
    );
    if (!destructive) {
      return ButtonStyle(
        side: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? disabledSide : null,
        ),
      );
    }
    return OutlinedButton.styleFrom(foregroundColor: scheme.error).copyWith(
      side: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? disabledSide
            : BorderSide(color: scheme.error, width: 1.5),
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused)) {
          return scheme.error.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.hovered)) {
          return scheme.error.withValues(alpha: 0.04);
        }
        return null;
      }),
    );
  }
}

/// Shrinks its child to 97% while a pointer is down.
///
/// A [Listener] rather than a gesture detector, so it never competes with the
/// button's own tap recognizer.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed && widget.enabled ? 0.97 : 1,
        duration: AppMotion.of(context, AppDurations.fast),
        curve: AppCurves.standard,
        child: widget.child,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          strokeCap: StrokeCap.round,
          // ButtonStyleButton exposes the resolved foreground via IconTheme.
          color: IconTheme.of(context).color,
          // No track ring: the theme's surfaceVariant track would read as a
          // pale ring on the CTA gradient.
          backgroundColor: Colors.transparent,
        ),
      );
    }
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 20), const Gap.sm(), Text(label)],
    );
  }
}
