import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';

/// One option of an [AppChoiceChips].
typedef ChipOption<T> = ({T value, String label});

/// Horizontal row of mutually exclusive chips, used as a quick filter
/// ("Todos", "Entradas", "Saídas"). Scrolls sideways when it does not fit.
class AppChoiceChips<T> extends StatelessWidget {
  const AppChoiceChips({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<ChipOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (index, option) in options.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              label: Text(option.label),
              selected: option.value == selected,
              showCheckmark: false,
              onSelected: (_) => onSelected(option.value),
            ),
          ],
        ],
      ),
    );
  }
}
