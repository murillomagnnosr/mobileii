import 'package:carteira_core/carteira_core.dart';
import 'package:design_system_ponto/design_system.dart';
import 'package:flutter/material.dart';

import '../shared/transaction_display.dart';
import 'transaction_form_view_model.dart';

class TransactionFormView extends StatefulWidget {
  const TransactionFormView({required this.viewModel, super.key});

  final TransactionFormViewModel viewModel;

  @override
  State<TransactionFormView> createState() => _TransactionFormViewState();
}

class _TransactionFormViewState extends State<TransactionFormView> {
  // Os controllers só carregam o valor inicial; a verdade fica no ViewModel.
  late final _amount = TextEditingController(text: widget.viewModel.amount);
  late final _description = TextEditingController(
    text: widget.viewModel.description,
  );
  late final _account = TextEditingController(text: widget.viewModel.account);
  late final _toAccount = TextEditingController(
    text: widget.viewModel.toAccount,
  );
  late final _category = TextEditingController(text: widget.viewModel.category);
  late final _note = TextEditingController(text: widget.viewModel.note);
  late final _date = TextEditingController(text: widget.viewModel.dateText);

  @override
  void dispose() {
    for (final controller in [
      _amount,
      _description,
      _account,
      _toAccount,
      _category,
      _note,
      _date,
    ]) {
      controller.dispose();
    }
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final current = widget.viewModel.date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) widget.viewModel.onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => DsScaffold(
        title: viewModel.title,
        body: ListView(
          children: [
            const DsGap.sm(),
            DsTransactionKindSelector(
              selected: viewModel.type.kind,
              enabled: !viewModel.isSaving,
              onChanged: (kind) => viewModel.onTypeChanged(kind.type),
            ),
            const DsGap(20),
            // O valor é o foco do formulário: tipografia grande e "R$" fixo
            // no lugar do ícone de dólar.
            DsTextField(
              key: const Key('form_amount'),
              label: 'Valor',
              hint: '0,00',
              controller: _amount,
              prefixText: r'R$ ',
              style: DsTypography.headline.copyWith(
                color: context.ds.textPrimary,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              errorText: viewModel.errorOf('amount'),
              onChanged: viewModel.onAmountChanged,
            ),
            const DsGap.md(),
            DsTextField(
              key: const Key('form_description'),
              label: 'Descrição',
              controller: _description,
              icon: Icons.short_text_rounded,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              errorText: viewModel.errorOf('description'),
              onChanged: viewModel.onDescriptionChanged,
            ),
            const DsGap.md(),
            DsTextField(
              key: const Key('form_account'),
              label: viewModel.type == TransactionType.transfer
                  ? 'Conta de origem'
                  : 'Conta',
              hint: 'Nubank',
              controller: _account,
              icon: Icons.account_balance_wallet_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              errorText: viewModel.errorOf('account'),
              onChanged: viewModel.onAccountChanged,
            ),
            const DsGap.md(),
            if (viewModel.type == TransactionType.transfer)
              DsTextField(
                key: const Key('form_to_account'),
                label: 'Conta de destino',
                hint: 'Itaú',
                controller: _toAccount,
                icon: Icons.call_made_rounded,
                textCapitalization: TextCapitalization.words,
                errorText: viewModel.errorOf('toAccount'),
                onChanged: viewModel.onToAccountChanged,
              )
            else
              DsTextField(
                key: const Key('form_category'),
                label: 'Categoria (opcional)',
                hint: 'Alimentação',
                controller: _category,
                icon: Icons.sell_outlined,
                textCapitalization: TextCapitalization.sentences,
                onChanged: viewModel.onCategoryChanged,
              ),
            const DsGap.md(),
            // Só exibe a data; o toque abre o seletor.
            DsTextField(
              key: const Key('form_date'),
              label: 'Data',
              controller: _date..text = viewModel.dateText,
              icon: Icons.event_outlined,
              readOnly: true,
              onTap: viewModel.isSaving ? null : _pickDate,
              errorText: viewModel.errorOf('date'),
            ),
            const DsGap.md(),
            DsTextField(
              key: const Key('form_note'),
              label: 'Observação (opcional)',
              controller: _note,
              icon: Icons.notes_rounded,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              onChanged: viewModel.onNoteChanged,
            ),
            if (viewModel.errorMessage != null) ...[
              const DsGap.md(),
              DsErrorBanner(
                viewModel.errorMessage!,
                textKey: const Key('form_error'),
              ),
            ],
            const DsGap(28),
            DsButtonFactory.primary(
              key: const Key('form_submit'),
              label: 'Salvar',
              isLoading: viewModel.isSaving,
              onPressed: viewModel.submit,
            ),
            const DsGap.xl(),
          ],
        ),
      ),
    );
  }
}
