import 'dart:async';

import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_digital/scenes/login/login_coordinator.dart';
import 'package:carteira_digital/scenes/login/login_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

class _FakeCoordinator implements LoginCoordinator {
  int successes = 0;

  @override
  void onLoginSuccess() => successes++;
}

void main() {
  test('submit sem senha mostra erro e não chama o servidor', () async {
    final auth = FakeAuth();
    final coordinator = _FakeCoordinator();
    final viewModel = LoginViewModel(auth: auth, coordinator: coordinator);

    viewModel.onEmailChanged('ana@carteira.dev');
    await viewModel.submit();

    expect(viewModel.errorMessage, 'Informe e-mail e senha.');
    expect(viewModel.isLoading, isFalse);
    expect(auth.loginCalls, 0);
    expect(coordinator.successes, 0);
  });

  test('login com sucesso chama o repositório e segue para a home', () async {
    final auth = FakeAuth();
    final coordinator = _FakeCoordinator();
    final viewModel = LoginViewModel(auth: auth, coordinator: coordinator);

    viewModel.onEmailChanged('  ana@carteira.dev ');
    viewModel.onPasswordChanged('123456');
    await viewModel.submit();

    expect(auth.loginCalls, 1);
    expect(auth.lastEmail, 'ana@carteira.dev');
    expect(auth.lastPassword, '123456');
    expect(coordinator.successes, 1);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test('credenciais erradas mostram a mensagem do Core na tela', () async {
    final auth = FakeAuth(
      error: const UnauthorizedError(invalidCredentials: true),
    );
    final coordinator = _FakeCoordinator();
    final viewModel = LoginViewModel(auth: auth, coordinator: coordinator);

    viewModel.onEmailChanged('ana@carteira.dev');
    viewModel.onPasswordChanged('errada');
    await viewModel.submit();

    expect(viewModel.errorMessage, 'E-mail ou senha incorretos.');
    expect(viewModel.isLoading, isFalse);
    expect(coordinator.successes, 0);
  });

  test('servidor fora do ar mostra erro de conexão', () async {
    final viewModel = LoginViewModel(
      auth: FakeAuth(error: const NetworkError()),
      coordinator: _FakeCoordinator(),
    );

    viewModel.onEmailChanged('ana@carteira.dev');
    viewModel.onPasswordChanged('123456');
    await viewModel.submit();

    expect(viewModel.errorMessage, const NetworkError().message);
  });

  test(
    'toques repetidos durante o carregamento não repetem a chamada',
    () async {
      final gate = Completer<void>();
      final auth = FakeAuth(gate: gate);
      final coordinator = _FakeCoordinator();
      final viewModel = LoginViewModel(auth: auth, coordinator: coordinator);

      viewModel.onEmailChanged('ana@carteira.dev');
      viewModel.onPasswordChanged('123456');
      final first = viewModel.submit();
      expect(viewModel.isLoading, isTrue);

      await viewModel.submit();
      expect(auth.loginCalls, 1);

      gate.complete();
      await first;
      expect(coordinator.successes, 1);
    },
  );
}
