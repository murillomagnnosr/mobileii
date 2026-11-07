// Dados iniciais do mock: os dois usuários de teste e os lançamentos que cada
// sessão recebe ao fazer login (e de novo a cada POST /reset).

/// Senha dos dois usuários de teste.
const seedPassword = '123456';

/// Usuários de teste, indexados pelo e-mail (em minúsculas).
const seedUsers = <String, Map<String, Object?>>{
  'ana@carteira.dev': {
    'id': 'usr_01',
    'name': 'Ana Ribeiro',
    'email': 'ana@carteira.dev',
    'avatarUrl': null,
    'createdAt': '2024-03-11T09:00:00Z',
  },
  'bruno@carteira.dev': {
    'id': 'usr_02',
    'name': 'Bruno Lima',
    'email': 'bruno@carteira.dev',
    'avatarUrl': null,
    'createdAt': '2024-05-02T10:00:00Z',
  },
};

/// Número usado no id do primeiro lançamento criado por POST (`tx_0081`).
///
/// O seed vai de `tx_0001` a `tx_0060` e não tem `tx_0061`–`tx_0080`: a
/// referência do curso mostra `tx_0060` como o lançamento mais recente e
/// `tx_0081` como o primeiro criado, e o mock reproduz os dois exemplos.
const seedNextId = 81;

/// Quantidade de lançamentos do seed (`tx_0001` a `tx_0060`).
const seedTransactionCount = 60;

/// Mês `YYYY-MM` de [now] em UTC, recuado [back] meses.
String monthOf(DateTime now, [int back = 0]) {
  final utc = now.toUtc();
  final date = DateTime.utc(utc.year, utc.month - back);
  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

/// Os 60 lançamentos do seed, do mais recente para o mais antigo, com os ids
/// em ordem cronológica:
///
/// - mês de [now]: `tx_0055`–`tx_0060` (4 despesas, o salário e uma
///   transferência de 500). Receitas 9526.55, despesas 5330.04 e saldo
///   4196.51, os números do exemplo de `/summary` da referência;
/// - mês anterior: `tx_0051`–`tx_0054`;
/// - os cinco meses antes dele: 10 lançamentos por mês (`tx_0001`–`tx_0050`),
///   para a paginação do extrato (20 por página) ter mais de uma página.
///
/// Um lançamento do mês atual que cairia depois de [now] (no começo do mês)
/// fica com a data de [now], truncada ao minuto: o seed nunca tem datas no
/// futuro, e o empate de datas é desfeito pelo id na listagem.
List<Map<String, Object?>> seedTransactions(DateTime now) {
  final utc = now.toUtc();
  final cap = DateTime.utc(utc.year, utc.month, utc.day, utc.hour, utc.minute);
  final result = <Map<String, Object?>>[];

  void tx(
    int number,
    String type,
    num amount,
    String description,
    String? category,
    (int back, int day, int hour, int minute) when,
    String account, {
    String? note,
    String? toAccount,
  }) {
    final (back, day, hour, minute) = when;
    final date = DateTime.utc(utc.year, utc.month - back, day, hour, minute);
    result.add({
      'id': 'tx_${number.toString().padLeft(4, '0')}',
      'type': type,
      'amount': amount.toDouble(),
      'description': description,
      'category': category,
      'date': _iso(date.isAfter(cap) ? cap : date),
      'note': note,
      'account': account,
      'toAccount': toAccount,
    });
  }

  // Mês atual.
  tx(
    60,
    'expense',
    306.7,
    'Mercado Pão de Açúcar',
    'Alimentação',
    (0, 27, 20, 55),
    'Nubank',
    note: 'Dividido com a Carla',
  );
  tx(59, 'income', 9526.55, 'Salário', 'Renda', (0, 25, 12, 0), 'Itaú');
  tx(
    58,
    'transfer',
    500,
    'Reserva',
    null,
    (0, 20, 9, 0),
    'Nubank',
    toAccount: 'Itaú',
  );
  tx(57, 'expense', 89.9, 'Mercado', 'Alimentação', (0, 6, 14, 32), 'Nubank');
  tx(56, 'expense', 4813.44, 'Aluguel', 'Moradia', (0, 5, 8, 0), 'Itaú');
  tx(55, 'expense', 120, 'Internet', 'Casa', (0, 3, 8, 0), 'Itaú');

  // Mês anterior.
  tx(54, 'expense', 64.5, 'Farmácia', 'Saúde', (1, 28, 18, 10), 'Nubank');
  tx(53, 'income', 9526.55, 'Salário', 'Renda', (1, 25, 12, 0), 'Itaú');
  tx(52, 'expense', 42.9, 'Streaming', 'Lazer', (1, 15, 10, 0), 'Nubank');
  tx(51, 'expense', 4813.44, 'Aluguel', 'Moradia', (1, 5, 8, 0), 'Itaú');

  // Histórico: 10 lançamentos por mês, do mês -2 (tx_0041–tx_0050) ao
  // mês -6 (tx_0001–tx_0010). Os valores variáveis mudam de mês a mês.
  for (var i = 0; i < _history.length; i++) {
    final back = i + 2;
    final first = 50 - 10 * i - 9;
    final (market, restaurant, fuel, pharmacy) = _history[i];
    tx(first + 9, 'expense', 99.9, 'Academia', 'Saúde', (
      back,
      28,
      21,
      0,
    ), 'Nubank');
    tx(first + 8, 'income', 9526.55, 'Salário', 'Renda', (
      back,
      25,
      12,
      0,
    ), 'Itaú');
    tx(first + 7, 'expense', pharmacy, 'Farmácia', 'Saúde', (
      back,
      22,
      18,
      10,
    ), 'Nubank');
    tx(
      first + 6,
      'transfer',
      500,
      'Reserva',
      null,
      (back, 20, 9, 0),
      'Nubank',
      toAccount: 'Itaú',
    );
    tx(first + 5, 'expense', fuel, 'Combustível', 'Transporte', (
      back,
      18,
      7,
      45,
    ), 'Nubank');
    tx(first + 4, 'expense', 42.9, 'Streaming', 'Lazer', (
      back,
      15,
      10,
      0,
    ), 'Nubank');
    tx(first + 3, 'expense', restaurant, 'Restaurante', 'Alimentação', (
      back,
      12,
      12,
      30,
    ), 'Nubank');
    tx(first + 2, 'expense', market, 'Mercado', 'Alimentação', (
      back,
      8,
      19,
      20,
    ), 'Nubank');
    tx(first + 1, 'expense', 4813.44, 'Aluguel', 'Moradia', (
      back,
      5,
      8,
      0,
    ), 'Itaú');
    tx(first, 'expense', 120, 'Internet', 'Casa', (back, 3, 8, 0), 'Itaú');
  }
  return result;
}

/// Valores variáveis do histórico (mercado, restaurante, combustível,
/// farmácia), do mês -2 ao mês -6.
const _history = <(num, num, num, num)>[
  (412.35, 86.4, 210, 58.9),
  (388.9, 112.5, 185.5, 34.5),
  (455.12, 74.9, 240.75, 72.1),
  (397.6, 98.3, 198.2, 41.8),
  (421.08, 131.2, 225, 63.25),
];

/// `2026-09-06T14:32:00Z`: UTC, sem frações de segundo.
String _iso(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-${two(date.month)}-'
      '${two(date.day)}T${two(date.hour)}:${two(date.minute)}:00Z';
}
