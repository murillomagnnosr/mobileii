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
            // Mesma tag do ProfileHeader: o avatar voa até o Perfil.
            icon: AppAvatar(
              name: viewModel.userName,
              size: 36,
              heroTag: 'profile-avatar',
            ),
            onPressed: viewModel.openProfile,
          ),
        ),
      ],
      floatingActionButton: AppFab(
        key: const Key('home_new'),
        tooltip: 'Novo lançamento',
        onPressed: viewModel.newTransaction,
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
      // Embaixo, espaço para o FAB não cobrir o último item; a lista passa
      // por trás da barra de gestos, então soma também essa área.
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.fabClearance + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Text(viewModel.greeting, style: theme.textTheme.titleLarge),
        const Gap.lg(),
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
        if (viewModel.recent.isEmpty)
          const AppPanel(
            child: StateView.empty(message: 'Nenhum lançamento neste mês.'),
          )
        else
          for (final (index, transaction) in viewModel.recent.indexed) ...[
            if (index > 0) const Gap.sm(),
            // Cápsulas flutuantes que entram em sequência. O tile põe o
            // sinal conforme o tipo; o valor vai sem sinal.
            TransactionTile(
              capsule: true,
              entranceIndex: index,
              kind: transaction.kind,
              title: transaction.description,
              amount: viewModel.amountOf(transaction),
              subtitle: viewModel.subtitleOf(transaction),
              onTap: () => viewModel.openTransaction(transaction),
            ),
          ],
      ],
    );
  }
}

/// Recuo horizontal padrão da tela, para os estados de carga e erro.
class _Inset extends StatelessWidget {
  const _Inset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
    child: child,
  );
}
