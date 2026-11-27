import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';

/// Marca do app: quadrado arredondado em maré com um ponto coral.
class DsLogoMark extends StatelessWidget {
  final double size;

  const DsLogoMark({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.account_balance_wallet_rounded, size: size * 0.5, color: c.textOnAccent),
            Positioned(
              top: size * 0.16,
              right: size * 0.16,
              child: Container(
                width: size * 0.16,
                height: size * 0.16,
                decoration: BoxDecoration(color: c.highlight, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
