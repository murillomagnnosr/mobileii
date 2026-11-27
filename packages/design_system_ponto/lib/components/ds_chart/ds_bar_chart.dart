import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_motion_curves.dart';
import '../../tokens/ds_typography.dart';

/// Um grupo de barras (ex.: um mês com entradas e saídas).
@immutable
class DsBarGroup {
  final String label;
  final List<double> values;

  const DsBarGroup({required this.label, required this.values});
}

/// Gráfico de barras agrupadas com `CustomPainter`: as barras sobem ao
/// aparecer e o grupo tocado fica em destaque.
class DsBarChart extends StatelessWidget {
  final List<DsBarGroup> groups;

  /// Uma cor por posição de [DsBarGroup.values].
  final List<Color> seriesColors;
  final int? selectedIndex;
  final ValueChanged<int?>? onSelected;
  final double height;

  const DsBarChart({
    super.key,
    required this.groups,
    required this.seriesColors,
    this.selectedIndex,
    this.onSelected,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final dataKey = Object.hashAll([for (final g in groups) ...g.values]);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) => TweenAnimationBuilder<double>(
          key: ValueKey(dataKey),
          tween: Tween(begin: 0, end: 1),
          duration: dsDisableAnimations(context) ? Duration.zero : const Duration(milliseconds: 800),
          curve: DsCurves.emphasized,
          builder: (context, progress, _) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: onSelected == null || groups.isEmpty
                ? null
                : (details) {
                    final slot = constraints.maxWidth / groups.length;
                    final index = (details.localPosition.dx / slot).floor().clamp(0, groups.length - 1);
                    onSelected!(index == selectedIndex ? null : index);
                  },
            child: CustomPaint(
              size: Size(constraints.maxWidth, height),
              painter: _BarPainter(
                groups: groups,
                colors: seriesColors,
                selectedIndex: selectedIndex,
                progress: progress,
                gridColor: c.border,
                labelStyle: DsTypography.caption.copyWith(color: c.textSecondary),
                selectedLabelStyle: DsTypography.caption.copyWith(color: c.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<DsBarGroup> groups;
  final List<Color> colors;
  final int? selectedIndex;
  final double progress;
  final Color gridColor;
  final TextStyle labelStyle;
  final TextStyle selectedLabelStyle;

  _BarPainter({
    required this.groups,
    required this.colors,
    required this.selectedIndex,
    required this.progress,
    required this.gridColor,
    required this.labelStyle,
    required this.selectedLabelStyle,
  });

  static const _labelArea = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (groups.isEmpty) return;
    final chartHeight = size.height - _labelArea;
    final maxValue = groups.expand((g) => g.values).fold<double>(0, (m, v) => v > m ? v : m);

    // Linhas de apoio: base e dois níveis.
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final fraction in [0.0, 0.5, 1.0]) {
      final y = chartHeight - chartHeight * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final slot = size.width / groups.length;
    final seriesCount = groups.map((g) => g.values.length).fold<int>(0, (m, n) => n > m ? n : m);
    final barWidth = (slot * 0.62 / seriesCount).clamp(4.0, 22.0);
    const barGap = 4.0;
    final groupWidth = barWidth * seriesCount + barGap * (seriesCount - 1);

    for (final (gi, group) in groups.indexed) {
      final selected = gi == selectedIndex;
      final dimmed = selectedIndex != null && !selected;
      final left = slot * gi + (slot - groupWidth) / 2;

      for (final (si, value) in group.values.indexed) {
        final barHeight = maxValue <= 0 ? 0.0 : chartHeight * 0.96 * (value / maxValue) * progress;
        final x = left + si * (barWidth + barGap);
        final color = colors[si % colors.length];
        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x, chartHeight - barHeight, barWidth, barHeight),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        );
        canvas.drawRRect(rect, Paint()..color = dimmed ? color.withValues(alpha: 0.35) : color);
      }

      final painter = TextPainter(
        text: TextSpan(text: group.label, style: selected ? selectedLabelStyle : labelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: slot);
      painter.paint(canvas, Offset(slot * gi + (slot - painter.width) / 2, chartHeight + 8));
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.progress != progress ||
      old.selectedIndex != selectedIndex ||
      old.groups != groups ||
      old.gridColor != gridColor ||
      old.colors != colors;
}
