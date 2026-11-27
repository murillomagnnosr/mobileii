import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';

class DsNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const DsNavItem({required this.label, required this.icon, IconData? selectedIcon})
      : selectedIcon = selectedIcon ?? icon;
}

/// Barra de navegação inferior com cores dos papéis semânticos.
class DsNavigationBar extends StatelessWidget {
  final List<DsNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const DsNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: c.surface,
      indicatorColor: c.accentSoft,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final item in items)
          NavigationDestination(
            icon: Icon(item.icon, color: c.textSecondary),
            selectedIcon: Icon(item.selectedIcon, color: c.accent),
            label: item.label,
          ),
      ],
    );
  }
}
