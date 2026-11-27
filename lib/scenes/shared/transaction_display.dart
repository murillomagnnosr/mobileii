import 'package:carteira_core/carteira_core.dart';
import 'package:design_system_ponto/design_system.dart';

/// Adapter entre o modelo do core e o design system, que não conhece
/// [Transaction]. Usado por todas as cenas que mostram lançamentos.
extension TransactionDisplay on Transaction {
  DsTransactionKind get kind => type.kind;

  /// "06/09 · Nubank" ou "06/09 · Nubank → Itaú".
  String get subtitle {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final accounts = switch (this) {
      Transfer(:final toAccount) => '$account → $toAccount',
      _ => account,
    };
    return '$day/$month · $accounts';
  }
}

extension TransactionTypeDisplay on TransactionType {
  DsTransactionKind get kind => switch (this) {
    TransactionType.income => DsTransactionKind.income,
    TransactionType.expense => DsTransactionKind.expense,
    TransactionType.transfer => DsTransactionKind.transfer,
  };

  String get label => switch (this) {
    TransactionType.income => 'Entrada',
    TransactionType.expense => 'Saída',
    TransactionType.transfer => 'Transferência',
  };
}

extension TransactionKindDomain on DsTransactionKind {
  TransactionType get type => switch (this) {
    DsTransactionKind.income => TransactionType.income,
    DsTransactionKind.expense => TransactionType.expense,
    DsTransactionKind.transfer => TransactionType.transfer,
  };
}
