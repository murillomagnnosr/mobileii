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

  /// Recuo do divisor: 16 de padding do tile + 44 do orb + 16 de espaço,
  /// alinhado ao texto do lançamento.
  static const _dividerIndent = 76.0;

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return AppScaffold(
      title: 'Extrato',
      // Sem recuo: os chips rolam de ponta a ponta; o recuo da tela é
      // aplicado à busca, ao painel e ao botão.
      padded: false,
      floatingActionButton: AppFab(
        key: const Key('transactions_new'),
        tooltip: 'Novo lançamento',
        onPressed: viewModel.newTransaction,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => ListView(
          // Espaço para o FAB não cobrir o último item, mais a barra de gestos.
          padding: EdgeInsets.only(
            bottom:
                AppSpacing.fabClearance + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.md,
              ),
              child: AppTextField(
                key: const Key('transactions_search'),
                label: 'Buscar',
                hint: 'Descrição do lançamento',
                prefixIcon: Icons.search_rounded,
                pill: true,
                textInputAction: TextInputAction.search,
                onSubmitted: viewModel.onQuerySubmitted,
              ),
            ),
            AppChoiceChips<TransactionType?>(
              options: _filters,
              selected: viewModel.type,
              onSelected: viewModel.onTypeChanged,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
            ),
            const Gap.lg(),
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
          icon: Icons.search_off_rounded,
          actionLabel: 'Adicionar',
          onAction: viewModel.newTransaction,
        ),
      ];
    }
    return [
      // Um único painel de vidro com divisores recuados. Quando a ViewModel
      // expuser grupos por data, vira um SectionHeader + painel por grupo.
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        child: AppPanel(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (final (index, transaction) in viewModel.items.indexed) ...[
                if (index > 0)
                  const Divider(
                    indent: _dividerIndent,
                    endIndent: AppSpacing.lg,
                  ),
                TransactionTile(
                  kind: transaction.kind,
                  title: transaction.description,
                  amount: viewModel.amountOf(transaction),
                  subtitle: transaction.subtitle,
                  onTap: () => viewModel.openTransaction(transaction),
                ),
              ],
            ],
          ),
        ),
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
    ];
  }
}
