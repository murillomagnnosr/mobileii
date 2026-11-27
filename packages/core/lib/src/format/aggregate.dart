import '../models/transaction.dart';
import 'date_time_x.dart';

/// Rótulo das transações sem categoria.
const uncategorizedLabel = 'Sem categoria';

/// Total de uma categoria.
class CategoryTotal {
  const CategoryTotal({required this.category, required this.total});

  final String category;
  final double total;

  @override
  bool operator ==(Object other) =>
      other is CategoryTotal &&
      other.category == category &&
      other.total == total;

  @override
  int get hashCode => Object.hash(category, total);

  @override
  String toString() => 'CategoryTotal($category, $total)';
}

/// Soma os valores de [transactions] por categoria, do maior para o menor.
///
/// Categoria vazia ou ausente vira [uncategorizedLabel]. Quem chama decide
/// quais lançamentos entram (por exemplo, só as saídas de um mês).
List<CategoryTotal> totalsByCategory(Iterable<Transaction> transactions) {
  final totals = <String, double>{};
  for (final transaction in transactions) {
    final raw = transaction.category?.trim();
    final category = (raw == null || raw.isEmpty) ? uncategorizedLabel : raw;
    totals.update(
      category,
      (sum) => sum + transaction.amount,
      ifAbsent: () => transaction.amount,
    );
  }
  return [
    for (final entry in totals.entries)
      CategoryTotal(category: entry.key, total: entry.value),
  ]..sort((a, b) => b.total.compareTo(a.total));
}

/// Os [count] meses que terminam em [now], do mais antigo ao atual, como
/// chaves `YYYY-MM`. Passa por virada de ano.
List<String> recentMonthKeys(DateTime now, int count) {
  final local = now.toLocal();
  return [
    for (var back = count - 1; back >= 0; back--)
      DateTime(local.year, local.month - back).monthKey,
  ];
}
