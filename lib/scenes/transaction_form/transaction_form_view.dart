import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
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

  @override
  void dispose() {
    for (final controller in [
      _amount,
      _description,
      _account,
      _toAccount,
      _category,
      _note,
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
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => AppScaffold(
        title: viewModel.title,
        body: ListView(
          children: [
            const Gap.md(),
            TransactionKindSelector(
              selected: viewModel.type.kind,
              enabled: !viewModel.isSaving,
              onChanged: (kind) => viewModel.onTypeChanged(kind.type),
            ),
            const Gap.lg(),
            AppTextField(
              key: const Key('form_amount'),
              label: 'Valor',
              hint: '0,00',
              controller: _amount,
              prefixIcon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              errorText: viewModel.errorOf('amount'),
              onChanged: viewModel.onAmountChanged,
            ),
            const Gap.md(),
            AppTextField(
              key: const Key('form_description'),
              label: 'Descrição',
              controller: _description,
              prefixIcon: Icons.short_text,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              errorText: viewModel.errorOf('description'),
              onChanged: viewModel.onDescriptionChanged,
            ),
            const Gap.md(),
            AppTextField(
              key: const Key('form_account'),
              label: viewModel.type == TransactionType.transfer
                  ? 'Conta de origem'
                  : 'Conta',
              hint: 'Nubank',
              controller: _account,
              prefixIcon: Icons.account_balance_wallet_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              errorText: viewModel.errorOf('account'),
              onChanged: viewModel.onAccountChanged,
            ),
            const Gap.md(),
            if (viewModel.type == TransactionType.transfer)
              AppTextField(
                key: const Key('form_to_account'),
                label: 'Conta de destino',
                hint: 'Itaú',
                controller: _toAccount,
                prefixIcon: Icons.call_made,
                textCapitalization: TextCapitalization.words,
                errorText: viewModel.errorOf('toAccount'),
                onChanged: viewModel.onToAccountChanged,
              )
            else
              AppTextField(
                key: const Key('form_category'),
                label: 'Categoria (opcional)',
                hint: 'Alimentação',
                controller: _category,
                prefixIcon: Icons.sell_outlined,
                textCapitalization: TextCapitalization.sentences,
                onChanged: viewModel.onCategoryChanged,
              ),
            const Gap.md(),
            InkWell(
              onTap: viewModel.isSaving ? null : _pickDate,
              borderRadius: AppRadius.mdAll,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data',
                  prefixIcon: const Icon(Icons.event_outlined),
                  errorText: viewModel.errorOf('date'),
                ),
                child: Text(viewModel.dateText),
              ),
            ),
            const Gap.md(),
            AppTextField(
              key: const Key('form_note'),
              label: 'Observação (opcional)',
              controller: _note,
              prefixIcon: Icons.notes_outlined,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              onChanged: viewModel.onNoteChanged,
            ),
            if (viewModel.errorMessage != null) ...[
              const Gap.md(),
              Text(
                viewModel.errorMessage!,
                key: const Key('form_error'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const Gap.xl(),
            AppButton(
              key: const Key('form_submit'),
              label: 'Salvar',
              isLoading: viewModel.isSaving,
              onPressed: viewModel.submit,
            ),
            const Gap.xl(),
          ],
        ),
      ),
    );
  }
}
