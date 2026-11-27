import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_motion_curves.dart';
import '../../tokens/ds_typography.dart';

/// Uma fatia da [DsDonutChart].
@immutable
class DsChartSegment {
  final String label;
  final double value;
  final Color color;

  const DsChartSegment({required this.label, required this.value, required this.color});
}

/// Gráfico de rosca desenhado com `CustomPainter`: cresce ao aparecer e destaca
/// a fatia tocada. O texto do centro mostra o total ou a fatia escolhida.
class DsDonutChart extends StatelessWidget {
  final List<DsChartSegment> segments;
  final int? selectedIndex;
  final ValueChanged<int?>? onSelected;
  final String centerTitle;
  final String centerValue;
  final double size;
  final double strokeWidth;

  const DsDonutChart({
    super.key,
    required this.segments,
    required this.centerTitle,
    required this.centerValue,
    this.selectedIndex,
    this.onSelected,
    this.size = 220,
    this.strokeWidth = 30,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    // Recomeça a animação quando os dados mudam, não a cada rebuild.
    final dataKey = Object.hashAll([for (final s in segments) s.value]);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(dataKey),
        tween: Tween(begin: 0, end: 1),
        duration: dsDisableAnimations(context) ? Duration.zero : const Duration(milliseconds: 900),
        curve: DsCurves.emphasized,
        builder: (context, progress, _) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: onSelected == null
              ? null
              : (details) => onSelected!(_hit(details.localPosition)),
          child: CustomPaint(
            painter: _DonutPainter(
              segments: segments,
              selectedIndex: selectedIndex,
              progress: progress,
              strokeWidth: strokeWidth,
              trackColor: c.surfaceVariant,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(strokeWidth + 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DsTypography.caption.copyWith(color: c.textSecondary),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        centerValue,
                        maxLines: 1,
                        style: DsTypography.title.copyWith(color: c.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Índice da fatia sob o toque, ou null se o toque caiu fora do anel.
  int? _hit(Offset position) {
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return null;
    final center = Offset(size / 2, size / 2);
    final delta = position - center;
    final radius = delta.distance;
    final outer = size / 2;
    if (radius > outer || radius < outer - strokeWidth - 12) return null;

    // 0 rad = topo, sentido horário, como o desenho.
    var angle = math.atan2(delta.dy, delta.dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    var start = 0.0;
    for (final (index, segment) in segments.indexed) {
      final sweep = segment.value / total * 2 * math.pi;
      if (angle >= start && angle < start + sweep) {
        return index == selectedIndex ? null : index;
      }
      start += sweep;
    }
    return null;
  }
}

class _DonutPainter extends CustomPainter {
  final List<DsChartSegment> segments;
  final int? selectedIndex;
  final double progress;
  final double strokeWidth;
  final Color trackColor;

  _DonutPainter({
    required this.segments,
    required this.selectedIndex,
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final extra = strokeWidth * 0.2;
    final radius = (size.shortestSide - strokeWidth - extra) / 2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: radius);

    canvas.drawCircle(
      rect.center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor,
    );

    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    const gap = 0.04;
    var start = -math.pi / 2;
    for (final (index, segment) in segments.indexed) {
      final full = segment.value / total * 2 * math.pi;
      final sweep = math.max(0.0, full - (segments.length > 1 ? gap : 0)) * progress;
      final selected = index == selectedIndex;
      final dimmed = selectedIndex != null && !selected;

      canvas.drawArc(
        rect,
        start + (segments.length > 1 ? gap / 2 : 0),
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = selected ? strokeWidth + extra : strokeWidth
          ..color = dimmed ? segment.color.withValues(alpha: 0.35) : segment.color,
      );
      start += full * progress;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress ||
      old.selectedIndex != selectedIndex ||
      old.segments != segments ||
      old.trackColor != trackColor;
}
