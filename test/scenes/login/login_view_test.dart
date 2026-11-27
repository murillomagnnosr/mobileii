import 'package:design_system_ponto/design_system.dart';
import 'package:carteira_digital/app/app_services.dart';
import 'package:carteira_digital/scenes/login/login_coordinator.dart';
import 'package:carteira_digital/scenes/login/login_factory.dart';
import 'package:carteira_digital/scenes/login/login_view.dart';
import 'package:carteira_digital/scenes/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

class _FakeCoordinator implements LoginCoordinator {
  int successes = 0;

  @override
  void onLoginSuccess() => successes++;
}

Widget _app(Widget home) => MaterialApp(theme: DsTheme.light(), home: home);

void main() {
  testWidgets('LoginFactory.make monta a cena de login', (tester) async {
    await tester.pumpWidget(_app(LoginFactory.make(AppServices.remote())));

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('mostra e-mail, senha e botão primário', (tester) async {
    final viewModel = LoginViewModel(
      auth: FakeAuth(),
      coordinator: _FakeCoordinator(),
    );
    await tester.pumpWidget(_app(LoginView(viewModel: viewModel)));

    expect(find.byType(DsTextField), findsNWidgets(2));
    expect(find.byType(DsPasswordField), findsOneWidget);
    final button = tester.widget<DsButtonComponent>(
      find.byKey(const Key('login_submit')),
    );
    expect(button.viewModel.variant, DsButtonVariant.primary);
  });

  testWidgets('enviar só com e-mail mostra erro e não chama o servidor', (
    tester,
  ) async {
    final auth = FakeAuth();
    final viewModel = LoginViewModel(
      auth: auth,
      coordinator: _FakeCoordinator(),
    );
    await tester.pumpWidget(_app(LoginView(viewModel: viewModel)));

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'ana@carteira.dev',
    );
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Informe e-mail e senha.'), findsOneWidget);
    expect(auth.loginCalls, 0);
  });
}
