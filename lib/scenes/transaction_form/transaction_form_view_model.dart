import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

import 'transaction_form_coordinator.dart';

/// Estado e ações do formulário de lançamento (criar e editar).
class TransactionFormViewModel extends ChangeNotifier {
  TransactionFormViewModel({
    required this._auth,
    required this._transactions,
    required this._coordinator,
    Transaction? initial,
    DateTime Function()? clock,
  }) : _initial = initial,
       _type = initial?.type ?? TransactionType.expense,
       _amount = initial == null ? '' : _formatAmount(initial.amount),
       _description = initial?.description ?? '',
       _account = initial?.account ?? '',
       _toAccount = switch (initial) {
         Transfer(:final toAccount) => toAccount,
         _ => '',
       },
       _category = initial?.category ?? '',
       _note = initial?.note ?? '',
       _date = initial?.date.toLocal() ?? (clock ?? DateTime.now)();

  final AuthRepository _auth;
  final TransactionRepository _transactions;
  final TransactionFormCoordinator _coordinator;
  final Transaction? _initial;

  TransactionType _type;
  String _amount;
  String _description;
  String _account;
  String _toAccount;
  String _category;
  String _note;
  DateTime _date;

  bool _isSaving = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = const {};

  bool get isEditing => _initial != null;
  String get title => isEditing ? 'Editar lançamento' : 'Novo lançamento';

  TransactionType get type => _type;
  String get amount => _amount;
  String get description => _description;
  String get account => _account;
  String get toAccount => _toAccount;
  String get category => _category;
  String get note => _note;
  DateTime get date => _date;
  String get dateText => formatDate(_date);

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  /// Mensagem do campo, ou null. Chaves iguais às do contrato da API.
  String? errorOf(String field) => _fieldErrors[field];

  void onTypeChanged(TransactionType type) => _update(() => _type = type);
  void onAmountChanged(String value) => _update(() => _amount = value);
  void onDescriptionChanged(String value) =>
      _update(() => _description = value);
  void onAccountChanged(String value) => _update(() => _account = value);
  void onToAccountChanged(String value) => _update(() => _toAccount = value);
  void onCategoryChanged(String value) => _update(() => _category = value);
  void onNoteChanged(String value) => _update(() => _note = value);

  /// Mantém o horário original ao trocar só o dia.
  void onDateChanged(DateTime day) => _update(
    () => _date = DateTime(
      day.year,
      day.month,
      day.day,
      _date.hour,
      _date.minute,
    ),
  );

  Future<void> submit() async {
    if (_isSaving) return;

    final errors = _validate();
    if (errors.isNotEmpty) {
      _fieldErrors = errors;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isSaving = true;
    _errorMessage = null;
    _fieldErrors = const {};
    notifyListeners();

    final transaction = _build();
    final result = isEditing
        ? await _transactions.update(transaction)
        : await _transactions.create(transaction);

    switch (result) {
      case Ok():
        _isSaving = false;
        _coordinator.onSaved();
      case Failure(error: UnauthorizedError()):
        await _auth.logout();
        _coordinator.onSessionExpired();
      case Failure(error: ValidationError(:final fields)):
        _isSaving = false;
        _fieldErrors = {for (final key in fields.keys) key: _invalid(key)};
        _errorMessage = 'Revise os campos destacados.';
        notifyListeners();
      case Failure(:final error):
        _isSaving = false;
        _errorMessage = error.message;
        notifyListeners();
    }
  }

  Map<String, String> _validate() => {
    'amount': ?validateAmount(_amount),
    'description': ?validateRequired(_description, field: 'A descrição'),
    'account': ?validateRequired(_account, field: 'A conta'),
    if (_type == TransactionType.transfer)
      'toAccount': ?validateRequired(_toAccount, field: 'A conta de destino'),
  };

  /// Factory Method: o tipo escolhido decide qual subclasse é criada.
  Transaction _build() {
    final id = _initial?.id ?? '';
    final amount = parseAmount(_amount)!;
    final description = _description.trim();
    final account = _account.trim();
    final category = _category.trim().isEmpty ? null : _category.trim();
    final note = _note.trim().isEmpty ? null : _note.trim();
    final date = _date.toUtc();
    return switch (_type) {
      TransactionType.income => Income(
        id: id,
        amount: amount,
        description: description,
        date: date,
        account: account,
        category: category,
        note: note,
      ),
      TransactionType.expense => Expense(
        id: id,
        amount: amount,
        description: description,
        date: date,
        account: account,
        category: category,
        note: note,
      ),
      TransactionType.transfer => Transfer(
        id: id,
        amount: amount,
        description: description,
        date: date,
        account: account,
        toAccount: _toAccount.trim(),
        note: note,
      ),
    };
  }

  void _update(VoidCallback change) {
    change();
    notifyListeners();
  }

  static String _invalid(String field) => switch (field) {
    'amount' => 'Valor inválido.',
    'description' => 'Descrição inválida.',
    'account' => 'Conta inválida.',
    'toAccount' => 'Conta de destino inválida.',
    'date' => 'Data inválida.',
    _ => 'Campo inválido.',
  };

  /// 89.9 -> "89,90", o formato que o usuário digita.
  static String _formatAmount(double amount) =>
      amount.toStringAsFixed(2).replaceAll('.', ',');
}
