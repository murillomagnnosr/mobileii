import 'dart:async';

import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart' hide Summary;

import 'insights_coordinator.dart';

/// Estado e ações do resumo: gastos por categoria no mês atual e entradas
/// contra saídas nos últimos meses.
class InsightsViewModel extends ChangeNotifier {
  InsightsViewModel({
    required this._auth,
    required this._transactions,
    required this._coordinator,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    // Qualquer criação, edição ou exclusão, em qualquer aba, atualiza os gráficos.
    _changes = _transactions.watch().listen((_) => load(silent: true));
  }

  /// Quantos meses o gráfico de barras mostra, contando o atual.
  static const monthsShown = 6;

  /// Acima disso, as menores categorias viram uma só: "Outras".
  static const maxCategories = 6;

  static const othersLabel = 'Outras';

  /// Páginas lidas ao somar as saídas do mês, para não pedir sem limite.
  static const _pageSize = 100;
  static const _maxPages = 5;

  final AuthRepository _auth;
  final TransactionRepository _transactions;
  final InsightsCoordinator _coordinator;
  final DateTime Function() _clock;
  late final StreamSubscription<List<Transaction>> _changes;

  final MoneyFormatter _money = MoneyFormatter.forCurrency(Currency.brl);

  bool _isLoading = true;
  bool _disposed = false;
  String? _errorMessage;
  String _month = '';
  List<Summary> _months = const [];
  List<CategoryTotal> _categories = const [];
  int? _selectedCategory;
  int? _selectedMonth;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Do mais antigo ao mês atual.
  List<Summary> get months => _months;

  /// Maiores primeiro, com "Outras" no fim se houver muitas.
  List<CategoryTotal> get categories => _categories;

  int? get selectedCategory => _selectedCategory;
  int? get selectedMonth => _selectedMonth;

  /// "Novembro de 2026".
  String get monthText {
    if (_month.isEmpty) return '';
    final label = formatMonthKey(_month);
    return label[0].toUpperCase() + label.substring(1);
  }

  double get totalExpense => _categories.fold(0, (sum, c) => sum + c.total);

  String format(double value) => _money.format(value);

  String amountOf(CategoryTotal category) => format(category.total);

  /// "42%".
  String shareOf(CategoryTotal category) {
    final total = totalExpense;
    if (total <= 0) return '0%';
    return '${(category.total / total * 100).round()}%';
  }

  /// Texto do centro da rosca: o total, ou a categoria escolhida.
  String get donutTitle {
    final index = _selectedCategory;
    return index == null ? 'Total de saídas' : _categories[index].category;
  }

  String get donutValue {
    final index = _selectedCategory;
    return format(index == null ? totalExpense : _categories[index].total);
  }

  /// "nov", "out"...
  String shortMonthOf(Summary summary) =>
      formatMonthKey(summary.month).split(' ').first.substring(0, 3);

  /// "Outubro de 2026" do mês escolhido no gráfico de barras.
  String? get selectedMonthTitle {
    final index = _selectedMonth;
    if (index == null) return null;
    final label = formatMonthKey(_months[index].month);
    return label[0].toUpperCase() + label.substring(1);
  }

  Summary? get selectedMonthSummary {
    final index = _selectedMonth;
    return index == null ? null : _months[index];
  }

  void selectCategory(int? index) {
    if (index == _selectedCategory) return;
    _selectedCategory = index;
    notifyListeners();
  }

  void selectMonth(int? index) {
    if (index == _selectedMonth) return;
    _selectedMonth = index;
    notifyListeners();
  }

  /// [silent] mantém o conteúdo na tela (puxar para atualizar, mudanças em outras abas).
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    final keys = recentMonthKeys(_clock(), monthsShown);
    final current = keys.last;

    // As consultas partem juntas; os repositórios não lançam.
    final summariesFuture = Future.wait([
      for (final key in keys) _transactions.summary(key),
    ]);
    final expensesFuture = _loadExpenses(current);

    final summaries = await summariesFuture;
    final expenses = await expensesFuture;
    if (_disposed) return;

    final failures = [
      for (final result in summaries) result.errorOrNull,
      expenses.errorOrNull,
    ].nonNulls.toList();

    if (failures.any((error) => error is UnauthorizedError)) {
      await _auth.logout();
      _coordinator.onSessionExpired();
      return;
    }

    if (failures.isEmpty) {
      _month = current;
      _months = [for (final result in summaries) result.valueOrNull!];
      _categories = _groupSmall(totalsByCategory(expenses.valueOrNull!));
      // Dados novos podem ter menos itens do que a escolha anterior.
      if ((_selectedCategory ?? 0) >= _categories.length) {
        _selectedCategory = null;
      }
      _errorMessage = null;
    } else if (!silent || _months.isEmpty) {
      _errorMessage = failures.first.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Junta as saídas do mês, lendo as páginas até acabarem (com um teto).
  Future<Result<List<Transaction>>> _loadExpenses(String month) async {
    final all = <Transaction>[];
    for (var page = 1; page <= _maxPages; page++) {
      final result = await _transactions.list(
        TransactionFilter(
          month: month,
          type: TransactionType.expense,
          page: page,
          pageSize: _pageSize,
        ),
      );
      switch (result) {
        case Failure(:final error):
          return Failure(error);
        case Ok(value: final data):
          all.addAll(data.items);
          if (!data.hasMore) return Ok(all);
      }
    }
    return Ok(all);
  }

  List<CategoryTotal> _groupSmall(List<CategoryTotal> totals) {
    if (totals.length <= maxCategories) return totals;
    final keep = totals.take(maxCategories - 1).toList();
    final rest = totals.skip(maxCategories - 1).fold<double>(
      0,
      (sum, c) => sum + c.total,
    );
    return [...keep, CategoryTotal(category: othersLabel, total: rest)];
  }

  @override
  void dispose() {
    _disposed = true;
    _changes.cancel();
    super.dispose();
  }
}
