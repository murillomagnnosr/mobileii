import 'package:flutter/material.dart';

import '../theme/app_effects.dart';

/// Page ground with three soft aurora washes (violet top-left, aqua right,
/// faint violet bottom-right) and an optional spotlight behind the Login
/// panel.
///
/// Static and non-interactive: wrapped in [IgnorePointer] and a
/// [RepaintBoundary]. No BackdropFilter.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, this.spotlight = false});

  /// Adds the aqua spotlight above the middle of the screen (Login).
  final bool spotlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = context.effects;
    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: theme.scaffoldBackgroundColor),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: e.wash(
                  e.auroraA,
                  center: const Alignment(-1.0, -1.1),
                  radius: 1.1,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: e.wash(
                  e.auroraB,
                  center: const Alignment(1.2, -0.15),
                  radius: 0.9,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: e.wash(
                  e.auroraC,
                  center: const Alignment(0.6, 1.25),
                  radius: 1.0,
                ),
              ),
            ),
            if (spotlight)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: e.wash(
                    e.spotlight,
                    center: const Alignment(0, -0.55),
                    radius: 0.7,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
