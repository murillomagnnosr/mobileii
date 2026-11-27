import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';

/// Botão flutuante de ação principal ("Novo lançamento"), em coral.
class DsFab extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  const DsFab({super.key, required this.tooltip, required this.onPressed, this.icon = Icons.add_rounded});

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return FloatingActionButton(
      tooltip: tooltip,
      onPressed: onPressed,
      elevation: 0,
      highlightElevation: 0,
      backgroundColor: c.highlight,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }
}
