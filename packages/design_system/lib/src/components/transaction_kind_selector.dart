import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import 'kind_style.dart';
import 'transaction_tile.dart';

/// Segmented control to pick income, expense or transfer in a form.
///
/// The selected segment is a SOLID fill in the kind color with an `onKind`
/// label, so it stands out from the page (WCAG 1.4.11). Everything else
/// (transparent rest, muted label, outline, pill shape, 52 tall) comes from
/// the theme's segmented button theme.
class TransactionKindSelector extends StatelessWidget {
  /// Creates the selector with [selected] highlighted.
  const TransactionKindSelector({
    required this.selected,
    required this.onChanged,
    super.key,
    this.enabled = true,
  });

  /// Highlighted kind, painted as a solid kind fill.
  final TransactionKind selected;

  /// Called with the tapped kind.
  final ValueChanged<TransactionKind> onChanged;

  /// False ignores taps, e.g. while the form saves.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final k = kindStyleOf(context, selected);

    ButtonSegment<TransactionKind> segment(TransactionKind kind, String label) {
      return ButtonSegment(
        value: kind,
        label: Text(label),
        // Arrows from the single kind mapping: up is money leaving.
        icon: Icon(kindStyleOf(context, kind).icon),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<TransactionKind>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: k.color,
          selectedForegroundColor: context.semanticColors.onKind,
        ),
        segments: [
          segment(TransactionKind.expense, 'Saída'),
          segment(TransactionKind.income, 'Entrada'),
          segment(TransactionKind.transfer, 'Transf.'),
        ],
        selected: {selected},
        onSelectionChanged: enabled ? (set) => onChanged(set.first) : null,
      ),
    );
  }
}
