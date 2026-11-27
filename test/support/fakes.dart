import 'dart:async';

import 'package:carteira_core/carteira_core.dart';

/// Autenticação falsa: conta as chamadas e devolve o resultado configurado.
class FakeAuth implements AuthRepository {
  FakeAuth({this.error, this.gate});

  final AppError? error;

  /// Quando presente, o login espera este completer antes de responder.
  final Completer<void>? gate;

  int loginCalls = 0;
  int logoutCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<Result<Session>> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;
    if (gate != null) await gate!.future;
    final failure = error;
    if (failure != null) return Failure(failure);
    return Ok(Session(token: 'tok_1', user: SampleData.user));
  }

  @override
  Future<Result<void>> logout() async {
    logoutCalls++;
    return Ok<void>(null);
  }

  @override
  Future<Result<Session?>> restore() async => Ok<Session?>(null);

  @override
  Session? get currentSession => null;
}

/// Lançamentos falsos: cada operação devolve o resultado configurado e
/// guarda os argumentos recebidos.
class FakeTransactions implements TransactionRepository {
  FakeTransactions({
    this.summaryResult,
    this.listResult,
    this.pages,
    this.getResult,
    this.saveResult,
    this.deleteResult,
  });

  final Result<Summary>? summaryResult;
  final Result<Page<Transaction>>? listResult;

  /// Quando presente, `list` devolve a página de número `filter.page`.
  final Map<int, Page<Transaction>>? pages;
  final Result<Transaction>? getResult;

  /// Usado por `create` e `update`. Sem ele, ecoa o lançamento recebido.
  final Result<Transaction>? saveResult;
  final Result<void>? deleteResult;

  final filters = <TransactionFilter>[];
  Transaction? created;
  Transaction? updated;
  String? deletedId;

  @override
  Future<Result<Summary>> summary(String month) async =>
      summaryResult ?? Ok(Summary(month: month, income: 0, expense: 0));

  @override
  Future<Result<Page<Transaction>>> list(TransactionFilter filter) async {
    filters.add(filter);
    final page = pages?[filter.page];
    if (page != null) return Ok(page);
    return listResult ?? const Ok(Page<Transaction>.empty());
  }

  @override
  Future<Result<Transaction>> getById(String id) async =>
      getResult ?? Failure(NotFoundError(id));

  @override
  Future<Result<Transaction>> create(Transaction transaction) async {
    created = transaction;
    return saveResult ?? Ok(transaction.copyWith(id: 'tx_new'));
  }

  @override
  Future<Result<Transaction>> update(Transaction transaction) async {
    updated = transaction;
    return saveResult ?? Ok(transaction);
  }

  @override
  Future<Result<void>> delete(String id) async {
    deletedId = id;
    return deleteResult ?? const Ok<void>(null);
  }

  @override
  Stream<List<Transaction>> watch() => const Stream.empty();
}

/// Perfil falso: devolve o usuário de exemplo ou o resultado configurado.
class FakeUsers implements UserRepository {
  FakeUsers({this.result, this.updateResult});

  final Result<User>? result;
  final Result<User>? updateResult;
  String? updatedName;

  @override
  Future<Result<User>> getProfile() async => result ?? Ok(SampleData.user);

  @override
  Future<Result<User>> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    updatedName = name;
    return updateResult ?? Ok(SampleData.user.copyWith(name: name.trim()));
  }
}
