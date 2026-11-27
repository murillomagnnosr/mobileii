import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';

/// Tipo de um lançamento, do ponto de vista do design system (sem conhecer o modelo do app).
enum DsTransactionKind { income, expense, transfer }

/// Identidade visual de um [DsTransactionKind]: cor, fundo suave e ícone.
///
/// A seta para baixo é dinheiro entrando; para cima, saindo. O tipo nunca
/// depende só da cor.
typedef DsKindStyle = ({Color color, Color container, IconData icon, String sign});

DsKindStyle dsKindStyleOf(BuildContext context, DsTransactionKind kind) {
  final c = context.ds;
  return switch (kind) {
    DsTransactionKind.income => (
        color: c.success,
        container: c.success.withValues(alpha: 0.14),
        icon: Icons.arrow_downward_rounded,
        sign: '+ ',
      ),
    DsTransactionKind.expense => (
        color: c.danger,
        container: c.danger.withValues(alpha: 0.14),
        icon: Icons.arrow_upward_rounded,
        sign: '− ',
      ),
    DsTransactionKind.transfer => (
        color: c.accent,
        container: c.accentSoft,
        icon: Icons.swap_horiz_rounded,
        sign: '',
      ),
  };
}

/// Círculo com a seta do tipo.
class DsKindOrb extends StatelessWidget {
  final DsTransactionKind kind;
  final double size;

  const DsKindOrb({super.key, required this.kind, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final style = dsKindStyleOf(context, kind);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: style.container, shape: BoxShape.circle),
      child: Icon(style.icon, size: size * 0.5, color: style.color),
    );
  }
}
