import 'package:flutter/material.dart';

import '../theme/app_effects.dart';
import '../tokens/app_durations.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';

/// Floating action button on the brand gradient (gradientStart to
/// gradientEnd, diagonal) with the FAB glow.
///
/// The gradient is painted by an ancestor [DecoratedBox] and the
/// [FloatingActionButton] itself is transparent, so its splash paints on top
/// of the gradient. The 60x60 size comes from the theme's `sizeConstraints`.
/// It pops in once (scale 0.8 to 1.0) on first appearance and shrinks
/// slightly while pressed. Nothing loops.
class AppFab extends StatelessWidget {
  const AppFab({
    required this.onPressed,
    this.tooltip,
    this.icon = Icons.add_rounded,
    super.key,
  });

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// Also the accessible label (screens pass 'Novo lançamento').
  final String? tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final e = context.effects;
    final overlay = e.onGradient;

    final fab = _PressScale(
      enabled: onPressed != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: e.ctaGradient.colors, // [gradientStart, gradientEnd]
          ),
          borderRadius: AppRadius.lgAll,
          boxShadow: e.fabGlow,
        ),
        child: FloatingActionButton(
          onPressed: onPressed,
          tooltip: tooltip,
          backgroundColor: Colors.transparent,
          foregroundColor: e.onGradient,
          // Same overlay recipe as the primary AppButton on the gradient.
          splashColor: overlay.withValues(alpha: 0.12),
          focusColor: overlay.withValues(alpha: 0.08),
          hoverColor: overlay.withValues(alpha: 0.08),
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          child: Icon(icon, size: 28),
        ),
      ),
    );

    // First appearance only: the tween's end never changes, so rebuilds do
    // not replay it.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: AppMotion.of(context, AppDurations.slow),
      curve: AppCurves.playful,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: fab,
    );
  }
}

/// Shrinks its child to 97% while a pointer is down.
///
/// Same behaviour as the press feedback of the primary AppButton (private
/// there too). A [Listener], so it never competes with the FAB's own tap.
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
