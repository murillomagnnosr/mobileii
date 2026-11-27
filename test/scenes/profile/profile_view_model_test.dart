import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_digital/app/theme_controller.dart';
import 'package:carteira_digital/scenes/profile/profile_coordinator.dart';
import 'package:carteira_digital/scenes/profile/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

class _FakeCoordinator implements ProfileCoordinator {
  int expired = 0;
  int loggedOut = 0;

  @override
  void onSessionExpired() => expired++;

  @override
  void onLoggedOut() => loggedOut++;
}

void main() {
  test('carrega o perfil', () async {
    final viewModel = ProfileViewModel(
      auth: FakeAuth(),
      users: FakeUsers(),
      theme: ThemeController(),
      coordinator: _FakeCoordinator(),
    );

    await viewModel.load();

    expect(viewModel.name, SampleData.user.name);
    expect(viewModel.email, SampleData.user.email);
    expect(viewModel.memberSince, startsWith('Cliente desde '));
  });

  test('nome vazio não é enviado', () async {
    final users = FakeUsers();
    final viewModel = ProfileViewModel(
      auth: FakeAuth(),
      users: users,
      theme: ThemeController(),
      coordinator: _FakeCoordinator(),
    );
    await viewModel.load();

    viewModel.onNameChanged('   ');
    await viewModel.saveName();

    expect(viewModel.nameError, isNotNull);
    expect(users.updatedName, isNull);
  });

  test('salvar nome atualiza o perfil', () async {
    final users = FakeUsers();
    final viewModel = ProfileViewModel(
      auth: FakeAuth(),
      users: users,
      theme: ThemeController(),
      coordinator: _FakeCoordinator(),
    );
    await viewModel.load();

    viewModel.onNameChanged('Ana R.');
    await viewModel.saveName();

    expect(users.updatedName, 'Ana R.');
    expect(viewModel.name, 'Ana R.');
    expect(viewModel.savedMessage, 'Nome atualizado.');
  });

  test('trocar o tema muda o controller do app', () {
    final theme = ThemeController();
    final viewModel = ProfileViewModel(
      auth: FakeAuth(),
      users: FakeUsers(),
      theme: theme,
      coordinator: _FakeCoordinator(),
    );

    expect(viewModel.themeMode, ThemeMode.light);
    viewModel.onThemeModeChanged(ThemeMode.dark);

    expect(theme.value, ThemeMode.dark);
    expect(viewModel.themeMode, ThemeMode.dark);
  });

  test('sair encerra a sessão e volta ao login', () async {
    final auth = FakeAuth();
    final coordinator = _FakeCoordinator();
    final viewModel = ProfileViewModel(
      auth: auth,
      users: FakeUsers(),
      theme: ThemeController(),
      coordinator: coordinator,
    );

    await viewModel.logout();

    expect(auth.logoutCalls, 1);
    expect(coordinator.loggedOut, 1);
  });
}
