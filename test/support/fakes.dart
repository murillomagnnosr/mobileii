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

/// Lançamentos falsos: resumo e lista configuráveis, o resto não é usado.
class FakeTransactions implements TransactionRepository {
  FakeTransactions({this.summaryResult, this.listResult});

  final Result<Summary>? summaryResult;
  final Result<Page<Transaction>>? listResult;

  @override
  Future<Result<Summary>> summary(String month) async =>
      summaryResult ?? Ok(Summary(month: month, income: 0, expense: 0));

  @override
  Future<Result<Page<Transaction>>> list(TransactionFilter filter) async =>
      listResult ?? const Ok(Page<Transaction>.empty());

  @override
  Future<Result<Transaction>> getById(String id) =>
      throw UnimplementedError('não usado nos testes');

  @override
  Future<Result<Transaction>> create(Transaction transaction) =>
      throw UnimplementedError('não usado nos testes');

  @override
  Future<Result<Transaction>> update(Transaction transaction) =>
      throw UnimplementedError('não usado nos testes');

  @override
  Future<Result<void>> delete(String id) =>
      throw UnimplementedError('não usado nos testes');

  @override
  Stream<List<Transaction>> watch() => const Stream.empty();
}

/// Perfil falso: devolve o usuário de exemplo ou o resultado configurado.
class FakeUsers implements UserRepository {
  FakeUsers({this.result});

  final Result<User>? result;

  @override
  Future<Result<User>> getProfile() async => result ?? Ok(SampleData.user);

  @override
  Future<Result<User>> updateProfile({
    required String name,
    String? avatarUrl,
  }) => throw UnimplementedError('não usado nos testes');
}
