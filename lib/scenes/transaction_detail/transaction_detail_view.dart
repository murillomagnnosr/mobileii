import 'package:design_system_ponto/design_system.dart';
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
    final confirmed = await showDsConfirmDialog(
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
      builder: (context, _) => DsScaffold(
        title: 'Lançamento',
        actions: [
          // Ganha o estilo de botão redondo do DsScaffold automaticamente.
          if (viewModel.transaction != null)
            IconButton(
              key: const Key('detail_edit'),
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_rounded),
              onPressed: viewModel.edit,
            ),
        ],
        body: _body(context, viewModel),
      ),
    );
  }

  Widget _body(BuildContext context, TransactionDetailViewModel viewModel) {
    if (viewModel.isLoading) return const DsStateView.loading();
    if (viewModel.errorMessage != null) {
      return DsStateView.error(
        message: viewModel.errorMessage!,
        onRetry: viewModel.load,
      );
    }

    return ListView(
      children: [
        const DsGap.sm(),
        _Header(viewModel: viewModel),
        const DsGap.lg(),
        _Details(viewModel: viewModel),
        if (viewModel.actionError != null) ...[
          const DsGap.md(),
          DsErrorBanner(viewModel.actionError!),
        ],
        const DsGap.xl(),
        DsButtonFactory.secondary(
          key: const Key('detail_delete'),
          label: 'Excluir lançamento',
          icon: Icons.delete_outline_rounded,
          destructive: true,
          isLoading: viewModel.isDeleting,
          onPressed: _confirmDelete,
        ),
        const DsGap.xl(),
      ],
    );
  }
}

/// Painel de destaque: ícone do tipo, pílula do tipo, descrição e valor
/// em tamanho display.
class _Header extends StatelessWidget {
  const _Header({required this.viewModel});

  final TransactionDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final kindStyle = dsKindStyleOf(context, viewModel.kind);

    return DsCard(
      padding: const EdgeInsets.all(DsSpacing.lg),
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DsKindOrb(kind: viewModel.kind, size: 52),
              const SizedBox(width: DsSpacing.md),
              // A pílula mostra o tipo, por isso não há linha "Tipo".
              Flexible(
                child: DsStatusPill(
                  label: viewModel.typeText,
                  tone: kindStyle.color,
                ),
              ),
            ],
          ),
          const DsGap.lg(),
          Text(
            viewModel.title,
            style: DsTypography.subtitle.copyWith(
              color: context.ds.textPrimary,
            ),
          ),
          const DsGap.xs(),
          DsMoneyText(
            viewModel.amountText,
            kind: viewModel.kind,
            size: DsMoneySize.display,
            signed: true,
          ),
        ],
      ),
    );
  }
}

/// Data, conta, categoria e observação num painel de vidro.
class _Details extends StatelessWidget {
  const _Details({required this.viewModel});

  final TransactionDetailViewModel viewModel;

  /// Alinha o divisor ao texto: 36 do ícone + 12 de espaço.
  static const _dividerIndent = 48.0;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.lg,
        vertical: DsSpacing.xs,
      ),
      child: Column(
        children: [
          DsDetailRow(
            label: 'Data',
            value: viewModel.dateText,
            icon: Icons.event_outlined,
          ),
          const Divider(indent: _dividerIndent),
          DsDetailRow(
            label: 'Conta',
            value: viewModel.accountText,
            icon: Icons.account_balance_wallet_outlined,
          ),
          const Divider(indent: _dividerIndent),
          DsDetailRow(
            label: 'Categoria',
            value: viewModel.categoryText,
            icon: Icons.sell_outlined,
          ),
          if (viewModel.noteText != null) ...[
            const Divider(indent: _dividerIndent),
            DsDetailRow(
              label: 'Observação',
              value: viewModel.noteText!,
              icon: Icons.notes_rounded,
            ),
          ],
        ],
      ),
    );
  }
}
