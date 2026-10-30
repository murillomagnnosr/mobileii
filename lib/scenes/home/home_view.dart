import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../shared/transaction_display.dart';
import 'home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({required this.viewModel, super.key});

  final HomeViewModel viewModel;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return AppScaffold(
      title: 'Carteira',
      // Lista sem recuo (full-bleed), como na galeria do design system;
      // o recuo da tela é aplicado só ao cabeçalho e ao card.
      padded: false,
      actions: [
        ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => IconButton(
            key: const Key('home_profile'),
            tooltip: 'Perfil',
            icon: AppAvatar(name: viewModel.userName, size: 32),
            onPressed: viewModel.openProfile,
          ),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        key: const Key('home_new'),
        tooltip: 'Novo lançamento',
        onPressed: viewModel.newTransaction,
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const _Inset(
              child: StateView.loading(message: 'Carregando sua carteira'),
            );
          }
          if (viewModel.errorMessage != null) {
            return _Inset(
              child: StateView.error(
                message: viewModel.errorMessage!,
                onRetry: viewModel.load,
              ),
            );
          }
          return _HomeContent(viewModel: viewModel);
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      children: [
        _Inset(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap.md(),
              Text(viewModel.greeting, style: theme.textTheme.titleLarge),
              const Gap.md(),
              BalanceCard(
                balance: viewModel.balanceText,
                income: viewModel.incomeText,
                expense: viewModel.expenseText,
                monthLabel: viewModel.monthText,
              ),
              // SectionHeader já traz o próprio espaçamento vertical.
              SectionHeader(
                title: 'Últimos lançamentos',
                actionLabel: 'Ver todos',
                onAction: viewModel.openStatement,
              ),
            ],
          ),
        ),
        if (viewModel.recent.isEmpty)
          const _Inset(
            child: StateView.empty(message: 'Nenhum lançamento neste mês.'),
          )
        else
          for (final transaction in viewModel.recent)
            // O tile põe o sinal conforme o tipo; o valor vai sem sinal.
            TransactionTile(
              kind: transaction.kind,
              title: transaction.description,
              amount: viewModel.amountOf(transaction),
              subtitle: viewModel.subtitleOf(transaction),
              onTap: () => viewModel.openTransaction(transaction),
            ),
        // Espaço para o FAB não cobrir o último item.
        const SizedBox(height: 88),
      ],
    );
  }
}

/// Recuo horizontal padrão da tela, para o que não é lista.
class _Inset extends StatelessWidget {
  const _Inset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
    child: child,
  );
}
