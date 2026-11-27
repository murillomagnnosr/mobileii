import 'package:design_system_ponto/design_system.dart';
import 'package:flutter/material.dart';

import '../../app/shell_controller.dart';

/// Casca do app depois do login: as quatro abas e a barra de navegação.
///
/// As abas ficam todas montadas (mantêm rolagem, filtros e dados ao trocar) e
/// a ativa aparece com um fade. A cena de cada aba vem pronta da Factory.
class ShellView extends StatelessWidget {
  const ShellView({required this.controller, required this.tabs, super.key})
    : assert(tabs.length == 4, 'uma cena por ShellTab');

  final ShellController controller;

  /// Na ordem de [ShellTab].
  final List<Widget> tabs;

  static const _items = [
    DsNavItem(
      label: 'Início',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    DsNavItem(
      label: 'Extrato',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
    DsNavItem(
      label: 'Resumo',
      icon: Icons.pie_chart_outline_rounded,
      selectedIcon: Icons.pie_chart_rounded,
    ),
    DsNavItem(
      label: 'Perfil',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ShellTab>(
      valueListenable: controller,
      builder: (context, tab, _) => PopScope(
        // Voltar numa aba que não é o Início leva ao Início antes de sair.
        canPop: tab == ShellTab.home,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.select(ShellTab.home);
        },
        child: Scaffold(
          body: Stack(
            children: [
              for (final (index, page) in tabs.indexed)
                _TabPage(visible: index == tab.index, child: page),
            ],
          ),
          bottomNavigationBar: DsNavigationBar(
            items: _items,
            selectedIndex: tab.index,
            onDestinationSelected: (index) =>
                controller.select(ShellTab.values[index]),
          ),
        ),
      ),
    );
  }
}

/// Uma aba: invisível e sem toque quando não é a ativa. Um fade de opacidade
/// zero nem chega a pintar o filho.
class _TabPage extends StatelessWidget {
  const _TabPage({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: !visible,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: DsMotion.normal,
          curve: DsCurves.emphasized,
          child: child,
        ),
      ),
    );
  }
}
