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
          // Ganha o estilo de botão redondo do AppScaffold automaticamente.
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
    if (viewModel.isLoading) return const StateView.loading();
    if (viewModel.errorMessage != null) {
      return StateView.error(
        message: viewModel.errorMessage!,
        onRetry: viewModel.load,
      );
    }

    return ListView(
      children: [
        const Gap.sm(),
        _Header(viewModel: viewModel),
        const Gap.lg(),
        _Details(viewModel: viewModel),
        if (viewModel.actionError != null) ...[
          const Gap.md(),
          AppErrorBanner(viewModel.actionError!),
        ],
        const Gap.xl(),
        AppButton.secondary(
          key: const Key('detail_delete'),
          label: 'Excluir lançamento',
          icon: Icons.delete_outline_rounded,
          destructive: true,
          isLoading: viewModel.isDeleting,
          onPressed: _confirmDelete,
        ),
        const Gap.xl(),
      ],
    );
  }
}

/// Painel de destaque com o brilho da cor do tipo: orb, pílula do tipo,
/// descrição e valor em tamanho display.
class _Header extends StatelessWidget {
  const _Header({required this.viewModel});

  final TransactionDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kindStyle = kindStyleOf(context, viewModel.kind);

    return AppPanel(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpacing.hero),
      glow: kindStyle.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KindOrb(kind: viewModel.kind, size: 52),
              const Gap.md(),
              // A pílula mostra o tipo, por isso não há mais a linha "Tipo".
              Flexible(
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: kindStyle.container,
                    shape: const StadiumBorder(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    child: Text(
                      viewModel.typeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: kindStyle.color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap.lg(),
          Text(viewModel.title, style: theme.textTheme.titleMedium),
          const Gap.xs(),
          // "R$" em meio tamanho; o valor encolhe em vez de ser cortado.
          MoneyText(
            viewModel.amountText,
            tone: kindStyle.tone,
            size: MoneySize.display,
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
    return AppPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: [
          DetailRow(
            label: 'Data',
            value: viewModel.dateText,
            icon: Icons.event_outlined,
          ),
          const Divider(indent: _dividerIndent),
          DetailRow(
            label: 'Conta',
            value: viewModel.accountText,
            icon: Icons.account_balance_wallet_outlined,
          ),
          const Divider(indent: _dividerIndent),
          DetailRow(
            label: 'Categoria',
            value: viewModel.categoryText,
            icon: Icons.sell_outlined,
          ),
          if (viewModel.noteText != null) ...[
            const Divider(indent: _dividerIndent),
            DetailRow(
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
