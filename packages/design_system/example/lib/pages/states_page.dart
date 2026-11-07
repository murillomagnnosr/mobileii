import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class StatesPage extends StatefulWidget {
  const StatesPage({super.key});

  @override
  State<StatesPage> createState() => _StatesPageState();
}

class _StatesPageState extends State<StatesPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final views = <Widget>[
      const StateView.loading(message: 'Carregando lançamentos…'),
      // The spark dot: one spot of the screen's spark budget.
      StateView.empty(
        message: 'Nenhum lançamento neste mês',
        actionLabel: 'Adicionar',
        onAction: () {},
      ),
      StateView.error(
        message: 'Não foi possível carregar. Verifique sua conexão.',
        onRetry: () {},
      ),
    ];
    return AppScaffold(
      title: 'Estados',
      actions: const [ThemeModeButton()],
      // Each state sits on a glass panel, as in Home and Extrato.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: AppPanel(child: views[_index]),
        ),
      ),
      bottom: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.hourglass_top_rounded),
            label: 'Loading',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_rounded),
            label: 'Empty',
          ),
          NavigationDestination(
            icon: Icon(Icons.error_outline_rounded),
            label: 'Error',
          ),
        ],
      ),
    );
  }
}
