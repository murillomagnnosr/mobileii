import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart' hide Summary;

import 'home_coordinator.dart';

/// Estado e ações da home.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._auth,
    required this._users,
    required this._transactions,
    required this._coordinator,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const recentCount = 5;

  final AuthRepository _auth;
  final UserRepository _users;
  final TransactionRepository _transactions;
  final HomeCoordinator _coordinator;
  final DateTime Function() _clock;

  final MoneyFormatter _money = MoneyFormatter.forCurrency(Currency.brl);

  bool _isLoading = true;
  String? _errorMessage;
  User? _user;
  Summary? _summary;
  List<Transaction> _recent = const [];
  String _month = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Transaction> get recent => _recent;

  String get greeting {
    final user = _user;
    if (user == null) return 'Olá';
    return 'Olá, ${user.name.split(' ').first}';
  }

  String get balanceText => _money.format(_summary?.balance ?? 0);
  String get incomeText => _money.format(_summary?.income ?? 0);
  String get expenseText => _money.format(_summary?.expense ?? 0);

  /// "Outubro de 2026".
  String get monthText {
    if (_month.isEmpty) return '';
    final label = formatMonthKey(_month);
    return label[0].toUpperCase() + label.substring(1);
  }

  /// Valor sem sinal: o tile põe o sinal conforme o tipo do lançamento.
  String amountOf(Transaction transaction) => _money.format(transaction.amount);

  /// "06/09 · Nubank".
  String subtitleOf(Transaction transaction) {
    final local = transaction.date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month · ${transaction.account}';
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final month = _clock().monthKey;
    _month = month;

    // As três chamadas partem juntas. Os repositórios não lançam, então
    // nenhuma delas fica sem dono se outra falhar.
    final profileFuture = _users.getProfile();
    final summaryFuture = _transactions.summary(month);
    final recentFuture = _transactions.list(
      TransactionFilter(month: month, pageSize: recentCount),
    );

    final profile = await profileFuture;
    final summary = await summaryFuture;
    final recent = await recentFuture;

    final failures = [
      profile.errorOrNull,
      summary.errorOrNull,
      recent.errorOrNull,
    ].nonNulls.toList();

    // Token inválido ou expirado: encerra a sessão local e volta ao login.
    if (failures.any((error) => error is UnauthorizedError)) {
      await _auth.logout();
      _coordinator.onSessionExpired();
      return;
    }

    _user = profile.valueOrNull;
    _summary = summary.valueOrNull;
    _recent = recent.valueOrNull?.items ?? const [];
    _errorMessage = failures.firstOrNull?.message;
    _isLoading = false;
    notifyListeners();
  }
}
