import 'package:flutter/material.dart';

import '../theme/app_effects.dart';

/// Brand mark: a wallet glyph on the brand gradient tile.
///
/// 72px on Login (with glow and, optionally, the spark dot), 28px in the
/// Home app bar. Decorative, so it is excluded from semantics.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 72, this.spark = false});

  final double size;

  /// Lime spark dot on the top-right corner (counts in the spark budget).
  final bool spark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = context.effects;
    final large = size >= 64;
    return ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              // gradientStart -> gradientEnd, diagonal.
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: e.ctaGradient.colors,
              ),
              borderRadius: BorderRadius.circular(large ? 24 : 9),
              boxShadow: large ? e.logoGlow : null,
            ),
            child: SizedBox.square(
              dimension: size,
              child: Center(
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: large ? 34 : 16,
                  color: e.onGradient,
                ),
              ),
            ),
          ),
          if (spark)
            Positioned(
              top: -3,
              right: -3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: e.spark,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: const SizedBox.square(dimension: 14),
              ),
            ),
        ],
      ),
    );
  }
}
