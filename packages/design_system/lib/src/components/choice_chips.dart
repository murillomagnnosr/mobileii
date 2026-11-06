import 'package:flutter/material.dart';

import 'gap.dart';

/// One option of an [AppChoiceChips].
typedef ChipOption<T> = ({T value, String label});

/// Horizontal row of mutually exclusive chips, used as a quick filter
/// ("Todos", "Entradas", "Saídas"). Scrolls sideways when it does not fit.
///
/// The look comes from the theme's chip theme: the selected chip is solid
/// primary with a small violet glow, the others a surface fill with an
/// outline border.
class AppChoiceChips<T> extends StatelessWidget {
  const AppChoiceChips({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
    this.padding = EdgeInsets.zero,
  });

  final List<ChipOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  /// Inset of the scrolling row, so it can run edge to edge while the first
  /// and last chips line up with the page gutter.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // The extra vertical room keeps the selected chip's glow unclipped.
      padding: padding.add(const EdgeInsets.symmetric(vertical: 4)),
      child: Row(
        children: [
          for (final (index, option) in options.indexed) ...[
            if (index > 0) const Gap.sm(),
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
