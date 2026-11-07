import 'package:flutter/material.dart';

import '../theme/app_effects.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

/// Glass panel: a tinted translucent surface with a hairline edge, a dark
/// top sheen (dark theme) and an ambient violet shadow (light theme).
///
/// It is a [Material], so ListTile and InkWell ripples inside it paint on the
/// panel and not on the Scaffold beneath the glass. There is no blur: it only
/// reads as glass over the AppBackdrop aurora.
class AppPanel extends StatelessWidget {
  /// Creates a glass panel around [child].
  const AppPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.panel),
    this.radius = AppRadius.lg,
    this.glow,
    this.shadows,
  });

  /// Content, laid out inside [padding].
  final Widget child;

  /// Inner padding. Defaults to [AppSpacing.panel] on every side; panels
  /// that hold list rows pass a tighter inset.
  final EdgeInsetsGeometry padding;

  /// Corner radius. Defaults to [AppRadius.lg]; hero-sized panels (Login,
  /// Detalhe header) use [AppRadius.xl].
  final double radius;

  /// Optional hue washed from the top-left corner at `kindGlowAlpha`
  /// (Detalhe header kind glow).
  final Color? glow;

  /// Outer shadows. Defaults to `AppEffects.panelShadow` (empty in dark).
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final e = context.effects;
    final borderRadius = BorderRadius.circular(radius);

    Widget content = Padding(padding: padding, child: child);

    final glow = this.glow;
    if (glow != null) {
      content = Ink(
        decoration: BoxDecoration(
          gradient: e.wash(
            glow.withValues(alpha: e.kindGlowAlpha),
            center: const Alignment(-1, -1),
            radius: 1.2,
          ),
        ),
        child: content,
      );
    }

    // The sheen is skipped when it is fully transparent (light theme).
    if (e.glassSheen.a > 0) {
      content = Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [e.glassSheen, e.glassSheen.withValues(alpha: 0)],
            stops: const [0, 0.4],
          ),
        ),
        child: content,
      );
    }

    Widget panel = Material(
      color: e.glass,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: e.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    final outer = shadows ?? e.panelShadow;
    if (outer.isNotEmpty) {
      panel = DecoratedBox(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          shadows: outer,
        ),
        child: panel,
      );
    }
    return panel;
  }
}
