import 'package:flutter/material.dart';

import 'transaction_tile.dart';

/// Segmented control to pick income, expense or transfer in a form.
class TransactionKindSelector extends StatelessWidget {
  const TransactionKindSelector({
    required this.selected,
    required this.onChanged,
    super.key,
    this.enabled = true,
  });

  final TransactionKind selected;
  final ValueChanged<TransactionKind> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<TransactionKind>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: TransactionKind.expense,
            label: Text('Saída'),
            icon: Icon(Icons.arrow_upward_rounded),
          ),
          ButtonSegment(
            value: TransactionKind.income,
            label: Text('Entrada'),
            icon: Icon(Icons.arrow_downward_rounded),
          ),
          ButtonSegment(
            value: TransactionKind.transfer,
            label: Text('Transf.'),
            icon: Icon(Icons.swap_horiz_rounded),
          ),
        ],
        selected: {selected},
        onSelectionChanged: enabled ? (set) => onChanged(set.first) : null,
      ),
    );
  }
}
