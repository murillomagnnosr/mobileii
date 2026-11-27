import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

/// Uma opção de [DsChoiceChips].
typedef ChipOption<T> = ({T value, String label});

/// Fileira de chips exclusivos, usada como filtro rápido. Rola na horizontal se não couber.
class DsChoiceChips<T> extends StatelessWidget {
  final List<ChipOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  const DsChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final (index, option) in options.indexed) ...[
            if (index > 0) const SizedBox(width: DsSpacing.xs),
            ChoiceChip(
              label: Text(option.label),
              selected: option.value == selected,
              showCheckmark: false,
              selectedColor: c.accent,
              labelStyle: DsTypography.label.copyWith(
                color: option.value == selected ? c.textOnAccent : c.textPrimary,
              ),
              onSelected: (_) => onSelected(option.value),
            ),
          ],
        ],
      ),
    );
  }
}
