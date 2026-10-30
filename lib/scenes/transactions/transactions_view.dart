import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../shared/transaction_display.dart';
import 'transactions_view_model.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({required this.viewModel, super.key});

  final TransactionsViewModel viewModel;

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
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

  static const _filters = <ChipOption<TransactionType?>>[
    (value: null, label: 'Todos'),
    (value: TransactionType.income, label: 'Entradas'),
    (value: TransactionType.expense, label: 'Saídas'),
    (value: TransactionType.transfer, label: 'Transferências'),
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return AppScaffold(
      title: 'Extrato',
      padded: false,
      floatingActionButton: FloatingActionButton(
        key: const Key('transactions_new'),
        tooltip: 'Novo lançamento',
        onPressed: viewModel.newTransaction,
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    key: const Key('transactions_search'),
                    label: 'Buscar',
                    hint: 'Descrição do lançamento',
                    prefixIcon: Icons.search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: viewModel.onQuerySubmitted,
                  ),
                  const Gap.md(),
                  AppChoiceChips<TransactionType?>(
                    options: _filters,
                    selected: viewModel.type,
                    onSelected: viewModel.onTypeChanged,
                  ),
                ],
              ),
            ),
            ..._content(viewModel),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(TransactionsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const [StateView.loading(message: 'Carregando lançamentos')];
    }
    if (viewModel.errorMessage != null) {
      return [
        StateView.error(
          message: viewModel.errorMessage!,
          onRetry: viewModel.load,
        ),
      ];
    }
    if (viewModel.items.isEmpty) {
      return [
        StateView.empty(
          message: 'Nenhum lançamento encontrado.',
          actionLabel: 'Adicionar',
          onAction: viewModel.newTransaction,
        ),
      ];
    }
    return [
      for (final transaction in viewModel.items)
        TransactionTile(
          kind: transaction.kind,
          title: transaction.description,
          amount: viewModel.amountOf(transaction),
          subtitle: transaction.subtitle,
          onTap: () => viewModel.openTransaction(transaction),
        ),
      if (viewModel.hasMore)
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: AppButton.secondary(
            key: const Key('transactions_more'),
            label: 'Carregar mais',
            isLoading: viewModel.isLoadingMore,
            onPressed: viewModel.loadMore,
          ),
        ),
      // Espaço para o FAB não cobrir o último item.
      const SizedBox(height: 88),
    ];
  }
}
