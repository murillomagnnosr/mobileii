import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_money_text.dart';
import 'ds_transaction_kind.dart';

/// Linha de lançamento: ícone do tipo, descrição, detalhe e valor.
///
/// Com [capsule], vira um cartão próprio (para a Home); sem ele, é só a linha,
/// para viver dentro de um painel com divisores (para o Extrato).
class DsTransactionTile extends StatelessWidget {
  final DsTransactionKind kind;
  final String title;
  final String amount;
  final String subtitle;
  final VoidCallback? onTap;
  final bool capsule;

  const DsTransactionTile({
    super.key,
    required this.kind,
    required this.title,
    required this.amount,
    required this.subtitle,
    this.onTap,
    this.capsule = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final row = Padding(
      padding: const EdgeInsets.all(DsSpacing.md),
      child: Row(
        children: [
          DsKindOrb(kind: kind),
          const SizedBox(width: DsSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsTypography.subtitle.copyWith(color: c.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsTypography.bodySmall.copyWith(color: c.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: DsSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: DsMoneyText(amount, kind: kind, signed: true),
          ),
        ],
      ),
    );

    final tappable = onTap == null ? row : InkWell(onTap: onTap, child: row);
    if (!capsule) return Material(color: Colors.transparent, child: tappable);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: tappable,
    );
  }
}
