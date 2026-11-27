import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_transaction_kind.dart';

/// Escolha entre Entrada, Saída e Transferência, com o ícone de cada tipo.
class DsTransactionKindSelector extends StatelessWidget {
  final DsTransactionKind selected;
  final ValueChanged<DsTransactionKind> onChanged;
  final bool enabled;

  const DsTransactionKindSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  static const _labels = {
    DsTransactionKind.income: 'Entrada',
    DsTransactionKind.expense: 'Saída',
    DsTransactionKind.transfer: 'Transferência',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return Row(
      children: [
        for (final (index, kind) in DsTransactionKind.values.indexed) ...[
          if (index > 0) const SizedBox(width: DsSpacing.xs),
          Expanded(
            child: Builder(builder: (context) {
              final style = dsKindStyleOf(context, kind);
              final isSelected = kind == selected;
              return Material(
                color: isSelected ? style.container : c.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DsRadius.md),
                  side: BorderSide(color: isSelected ? style.color : Colors.transparent, width: 1.5),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(DsRadius.md),
                  onTap: enabled ? () => onChanged(kind) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: DsSpacing.sm),
                    child: Column(
                      children: [
                        Icon(style.icon, color: isSelected ? style.color : c.textSecondary),
                        const SizedBox(height: DsSpacing.xxs),
                        Text(
                          _labels[kind]!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DsTypography.caption.copyWith(color: isSelected ? style.color : c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
