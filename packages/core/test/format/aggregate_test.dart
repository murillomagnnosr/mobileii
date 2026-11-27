import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

Expense _expense(double amount, {String? category}) => Expense(
  id: 'x',
  amount: amount,
  description: 'gasto',
  date: DateTime(2026, 11, 5),
  account: 'Nubank',
  category: category,
);

void main() {
  group('totalsByCategory', () {
    test('soma por categoria e ordena do maior para o menor', () {
      final totals = totalsByCategory([
        _expense(10, category: 'Mercado'),
        _expense(100, category: 'Moradia'),
        _expense(25.5, category: 'Mercado'),
      ]);

      expect(totals, [
        const CategoryTotal(category: 'Moradia', total: 100),
        const CategoryTotal(category: 'Mercado', total: 35.5),
      ]);
    });

    test('categoria nula ou em branco vira "Sem categoria"', () {
      final totals = totalsByCategory([
        _expense(5),
        _expense(7, category: '   '),
      ]);

      expect(totals, [
        const CategoryTotal(category: uncategorizedLabel, total: 12),
      ]);
    });

    test('lista vazia dá resultado vazio', () {
      expect(totalsByCategory(const []), isEmpty);
    });
  });

  group('recentMonthKeys', () {
    test('devolve do mais antigo ao atual', () {
      expect(recentMonthKeys(DateTime(2026, 11, 27), 3), [
        '2026-09',
        '2026-10',
        '2026-11',
      ]);
    });

    test('atravessa a virada de ano', () {
      expect(recentMonthKeys(DateTime(2026, 2, 10), 4), [
        '2025-11',
        '2025-12',
        '2026-01',
        '2026-02',
      ]);
    });
  });
}
