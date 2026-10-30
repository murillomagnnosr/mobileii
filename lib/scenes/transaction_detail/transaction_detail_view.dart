import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'transaction_detail_view_model.dart';

class TransactionDetailView extends StatefulWidget {
  const TransactionDetailView({required this.viewModel, super.key});

  final TransactionDetailViewModel viewModel;

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
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

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Excluir lançamento?',
      message: 'Essa ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmed) await widget.viewModel.delete();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => AppScaffold(
        title: 'Lançamento',
        actions: [
          if (viewModel.transaction != null)
            IconButton(
              key: const Key('detail_edit'),
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined),
              onPressed: viewModel.edit,
            ),
        ],
        body: _body(context, viewModel),
      ),
    );
  }

  Widget _body(BuildContext context, TransactionDetailViewModel viewModel) {
    if (viewModel.isLoading) return const StateView.loading();
    if (viewModel.errorMessage != null) {
      return StateView.error(
        message: viewModel.errorMessage!,
        onRetry: viewModel.load,
      );
    }

    final theme = Theme.of(context);
    final tone = switch (viewModel.kind) {
      TransactionKind.income => MoneyTone.income,
      TransactionKind.expense => MoneyTone.expense,
      TransactionKind.transfer => MoneyTone.neutral,
    };
    return ListView(
      children: [
        const Gap.xl(),
        Text(viewModel.title, style: theme.textTheme.titleMedium),
        const Gap.xs(),
        MoneyText(
          viewModel.amountText,
          tone: tone,
          size: MoneySize.display,
          signed: true,
        ),
        const Gap.lg(),
        const Divider(),
        DetailRow(
          label: 'Tipo',
          value: viewModel.typeText,
          icon: Icons.category_outlined,
        ),
        DetailRow(
          label: 'Data',
          value: viewModel.dateText,
          icon: Icons.event_outlined,
        ),
        DetailRow(
          label: 'Conta',
          value: viewModel.accountText,
          icon: Icons.account_balance_wallet_outlined,
        ),
        DetailRow(
          label: 'Categoria',
          value: viewModel.categoryText,
          icon: Icons.sell_outlined,
        ),
        if (viewModel.noteText != null)
          DetailRow(
            label: 'Observação',
            value: viewModel.noteText!,
            icon: Icons.notes_outlined,
          ),
        if (viewModel.actionError != null) ...[
          const Gap.md(),
          Text(
            viewModel.actionError!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const Gap.xl(),
        AppButton.secondary(
          key: const Key('detail_delete'),
          label: 'Excluir lançamento',
          icon: Icons.delete_outline,
          isLoading: viewModel.isDeleting,
          onPressed: _confirmDelete,
        ),
        const Gap.xl(),
      ],
    );
  }
}
