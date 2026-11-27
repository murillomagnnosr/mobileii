import 'package:flutter/widgets.dart';

import '../../tokens/ds_spacing.dart';

/// Espaço vertical entre blocos de uma coluna ou lista.
class DsGap extends StatelessWidget {
  final double size;

  const DsGap(this.size, {super.key});
  const DsGap.xs({super.key}) : size = DsSpacing.xs;
  const DsGap.sm({super.key}) : size = DsSpacing.sm;
  const DsGap.md({super.key}) : size = DsSpacing.md;
  const DsGap.lg({super.key}) : size = DsSpacing.lg;
  const DsGap.xl({super.key}) : size = DsSpacing.xl;
  const DsGap.xxl({super.key}) : size = DsSpacing.xxl;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}
