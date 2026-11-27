import 'package:design_system_ponto/design_system.dart';
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

    return DsScaffold(
      title: 'Carteira',
      // Logo de 28px antes do título.
      brand: true,
      // A lista aplica o próprio recuo, para as cápsulas e o espaço do FAB.
      padded: false,
      actions: [
        ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => IconButton(
            key: const Key('home_profile'),
            tooltip: 'Perfil',
            // O avatar não é botão de chrome: sem fundo nem borda.
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              fixedSize: const Size.square(44),
            ),
            icon: DsAvatar(name: viewModel.userName, size: 36),
            onPressed: viewModel.openProfile,
          ),
        ),
      ],
      floatingActionButton: DsFab(
        key: const Key('home_new'),
        tooltip: 'Novo lançamento',
        onPressed: viewModel.newTransaction,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const _Inset(
              child: DsStateView.loading(message: 'Carregando sua carteira'),
            );
          }
          if (viewModel.errorMessage != null) {
            return _Inset(
              child: DsStateView.error(
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

    return RefreshIndicator(
      onRefresh: () => viewModel.load(silent: true),
      child: ListView(
      // O pull-to-refresh precisa rolar mesmo com pouco conteúdo.
      physics: const AlwaysScrollableScrollPhysics(),
      // Embaixo, espaço para o FAB não cobrir o último item.
      padding: const EdgeInsets.fromLTRB(
        DsSpacing.screenGutter,
        DsSpacing.sm,
        DsSpacing.screenGutter,
        DsSpacing.fabClearance,
      ),
      children: [
        Text(viewModel.greeting, style: theme.textTheme.titleLarge),
        const DsGap.lg(),
        DsBalanceCard(
          balance: viewModel.balance,
          income: viewModel.income,
          expense: viewModel.expense,
          format: viewModel.formatMoney,
          monthLabel: viewModel.monthText,
        ),
        // DsSectionHeader já traz o próprio espaçamento vertical.
        DsSectionHeader(
          title: 'Últimos lançamentos',
          actionLabel: 'Ver todos',
          onAction: viewModel.openStatement,
        ),
        if (viewModel.recent.isEmpty)
          const DsCard(
            child: DsStateView.empty(message: 'Nenhum lançamento neste mês.'),
          )
        else
          for (final (index, transaction) in viewModel.recent.indexed) ...[
            if (index > 0) const DsGap.sm(),
            // Cápsulas flutuantes que entram em sequência. O tile põe o
            // sinal conforme o tipo; o valor vai sem sinal.
            DsEntrance(
              index: index,
              child: DsTransactionTile(
                capsule: true,
                kind: transaction.kind,
                title: transaction.description,
                amount: viewModel.amountOf(transaction),
                subtitle: viewModel.subtitleOf(transaction),
                onTap: () => viewModel.openTransaction(transaction),
              ),
            ),
          ],
      ],
    ),
    );
  }
}

/// Recuo horizontal padrão da tela, para os estados de carga e erro.
class _Inset extends StatelessWidget {
  const _Inset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: DsSpacing.screenGutter),
    child: child,
  );
}
