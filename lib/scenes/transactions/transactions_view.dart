import 'package:carteira_core/carteira_core.dart';
import 'package:design_system_ponto/design_system.dart';
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
  final _scroll = ScrollController();

  /// Distância do fim da lista (em pixels) a partir da qual a próxima página
  /// começa a ser buscada.
  static const _loadMoreThreshold = 400.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  /// Rolagem infinita: perto do fim, pede mais. O ViewModel ignora o pedido
  /// se já estiver carregando ou se não houver mais páginas.
  void _onScroll() {
    if (_scroll.hasClients &&
        _scroll.position.extentAfter < _loadMoreThreshold) {
      widget.viewModel.loadMore();
    }
  }

  static const _filters = <ChipOption<TransactionType?>>[
    (value: null, label: 'Todos'),
    (value: TransactionType.income, label: 'Entradas'),
    (value: TransactionType.expense, label: 'Saídas'),
    (value: TransactionType.transfer, label: 'Transferências'),
  ];

  /// Esconde o lançamento deslizado e dá 5 segundos para desfazer. Ao fechar
  /// o aviso sem desfazer (tempo, ou outro aviso no lugar), exclui de verdade.
  void _onDismissed(Transaction transaction) {
    final viewModel = widget.viewModel;
    viewModel.scheduleDelete(transaction);

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger
        .showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            content: Text('"${transaction.description}" excluído'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () => viewModel.undoDelete(transaction),
            ),
          ),
        )
        .closed
        .then((reason) async {
          if (reason == SnackBarClosedReason.action) return;
          final deleted = await viewModel.commitDelete(transaction);
          if (!deleted) {
            messenger.showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Não foi possível excluir. Tente de novo.'),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return DsScaffold(
      title: 'Extrato',
      // Sem recuo: os chips rolam de ponta a ponta; o recuo da tela é
      // aplicado à busca, ao painel e ao botão.
      padded: false,
      floatingActionButton: DsFab(
        key: const Key('transactions_new'),
        tooltip: 'Novo lançamento',
        onPressed: viewModel.newTransaction,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => RefreshIndicator(
          onRefresh: () => viewModel.load(silent: true),
          child: ListView(
            controller: _scroll,
            // O pull-to-refresh precisa rolar mesmo com pouco conteúdo.
            physics: const AlwaysScrollableScrollPhysics(),
            // Espaço para o FAB não cobrir o último item.
            padding: const EdgeInsets.only(bottom: DsSpacing.fabClearance),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DsSpacing.screenGutter,
                  DsSpacing.sm,
                  DsSpacing.screenGutter,
                  DsSpacing.md,
                ),
                child: DsTextField(
                  key: const Key('transactions_search'),
                  label: 'Buscar',
                  hint: 'Descrição do lançamento',
                  icon: Icons.search_rounded,
                  pill: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: viewModel.onQuerySubmitted,
                ),
              ),
              DsChoiceChips<TransactionType?>(
                options: _filters,
                selected: viewModel.type,
                onSelected: viewModel.onTypeChanged,
                padding: const EdgeInsets.symmetric(
                  horizontal: DsSpacing.screenGutter,
                ),
              ),
              const DsGap.lg(),
              ..._content(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, TransactionsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const [DsStateView.loading(message: 'Carregando lançamentos')];
    }
    if (viewModel.errorMessage != null) {
      return [
        DsStateView.error(
          message: viewModel.errorMessage!,
          onRetry: viewModel.load,
        ),
      ];
    }
    final items = viewModel.items;
    if (items.isEmpty) {
      return [
        DsStateView.empty(
          message: 'Nenhum lançamento encontrado.',
          icon: Icons.search_off_rounded,
          actionLabel: 'Adicionar',
          onAction: viewModel.newTransaction,
        ),
      ];
    }
    final danger = context.ds.danger;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsSpacing.screenGutter),
        child: DsCard(
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.xxs),
          child: Column(
            children: [
              for (final (index, transaction) in items.indexed) ...[
                if (index > 0) const Divider(indent: 76, endIndent: 24),
                // Deslizar para a esquerda exclui, com "Desfazer".
                Dismissible(
                  key: ValueKey(transaction.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _onDismissed(transaction),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: DsSpacing.lg),
                    color: danger.withValues(alpha: 0.18),
                    child: Icon(Icons.delete_outline_rounded, color: danger),
                  ),
                  child: DsEntrance(
                    index: index,
                    child: DsTransactionTile(
                      kind: transaction.kind,
                      title: transaction.description,
                      amount: viewModel.amountOf(transaction),
                      subtitle: transaction.subtitle,
                      onTap: () => viewModel.openTransaction(transaction),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      // Rolagem infinita: o spinner aparece enquanto a próxima página chega.
      if (viewModel.hasMore)
        const Padding(
          padding: EdgeInsets.all(DsSpacing.lg),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ),
    ];
  }
}
