import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_motion_curves.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

/// Cartão de saldo do mês: valor grande em maré e as duas pernas (entradas e saídas).
///
/// Os valores são números e o [format] os transforma em texto, para que eles
/// contem do valor anterior ao novo (de zero na primeira vez).
class DsBalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final String Function(double value) format;
  final String monthLabel;

  const DsBalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    required this.format,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final on = c.textOnAccent;
    return Container(
      padding: const EdgeInsets.all(DsSpacing.lg),
      decoration: BoxDecoration(
        color: c.accent,
        borderRadius: BorderRadius.circular(DsRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo de $monthLabel', style: DsTypography.label.copyWith(color: on.withValues(alpha: 0.85))),
          const SizedBox(height: DsSpacing.xs),
          _CountUp(
            value: balance,
            builder: (context, value) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(format(value), maxLines: 1, style: DsTypography.display.copyWith(color: on)),
            ),
          ),
          const SizedBox(height: DsSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Leg(
                  label: 'Entradas',
                  value: income,
                  format: format,
                  icon: Icons.arrow_downward_rounded,
                  color: on,
                ),
              ),
              Expanded(
                child: _Leg(
                  label: 'Saídas',
                  value: expense,
                  format: format,
                  icon: Icons.arrow_upward_rounded,
                  color: on,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Anima de zero até [value] na primeira vez e, depois, do valor atual ao novo.
class _CountUp extends StatelessWidget {
  final double value;
  final Widget Function(BuildContext context, double value) builder;

  const _CountUp({required this.value, required this.builder});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: dsDisableAnimations(context) ? Duration.zero : const Duration(milliseconds: 900),
      curve: DsCurves.emphasized,
      builder: (context, animated, _) => builder(context, animated),
    );
  }
}

class _Leg extends StatelessWidget {
  final String label;
  final double value;
  final String Function(double) format;
  final IconData icon;
  final Color color;

  const _Leg({
    required this.label,
    required this.value,
    required this.format,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.18), shape: BoxShape.circle),
          child: Icon(icon, size: DsSizes.iconMd - 4, color: color),
        ),
        const SizedBox(width: DsSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: DsTypography.caption.copyWith(color: color.withValues(alpha: 0.85))),
              _CountUp(
                value: value,
                builder: (context, animated) => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(format(animated), maxLines: 1, style: DsTypography.label.copyWith(color: color)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
