import 'dart:async';

import 'package:flutter/material.dart';

import '../../tokens/ds_motion_curves.dart';

/// Entrada escalonada: o filho aparece com fade e sobe um pouco, esperando
/// `index * step` antes de começar. O atraso para de crescer em [maxSteps]
/// para itens distantes não demorarem a aparecer.
class DsEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration step;
  final int maxSteps;

  const DsEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.step = const Duration(milliseconds: 45),
    this.maxSteps = 8,
  });

  @override
  State<DsEntrance> createState() => _DsEntranceState();
}

class _DsEntranceState extends State<DsEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  late final Animation<double> _curve = CurvedAnimation(parent: _controller, curve: DsCurves.emphasized);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final steps = widget.index.clamp(0, widget.maxSteps);
    if (steps == 0) {
      _controller.forward();
    } else {
      _timer = Timer(widget.step * steps, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (dsDisableAnimations(context)) return widget.child;
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
