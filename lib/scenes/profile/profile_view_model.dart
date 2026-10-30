import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/material.dart';

import '../../app/theme_controller.dart';
import 'profile_coordinator.dart';

/// Estado e ações do perfil: nome, tema e sair da conta.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required this._auth,
    required this._users,
    required this._theme,
    required this._coordinator,
  });

  final AuthRepository _auth;
  final UserRepository _users;
  final ThemeController _theme;
  final ProfileCoordinator _coordinator;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoggingOut = false;
  String? _errorMessage;
  String? _nameError;
  String? _savedMessage;
  User? _user;
  String _name = '';

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorMessage;
  String? get nameError => _nameError;

  /// "Nome atualizado." depois de salvar; some na próxima edição.
  String? get savedMessage => _savedMessage;

  String get name => _user?.name ?? '';
  String get email => _user?.email ?? '';
  String? get avatarUrl => _user?.avatarUrl;

  /// "Cliente desde março de 2024".
  String get memberSince {
    final user = _user;
    if (user == null) return '';
    return 'Cliente desde ${formatMonthKey(user.createdAt.monthKey)}';
  }

  ThemeMode get themeMode => _theme.value;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _users.getProfile();
    if (await _handleUnauthorized(result)) return;

    _user = result.valueOrNull;
    _name = _user?.name ?? '';
    _errorMessage = result.errorOrNull?.message;
    _isLoading = false;
    notifyListeners();
  }

  void onNameChanged(String value) {
    _name = value;
    _nameError = null;
    _savedMessage = null;
    notifyListeners();
  }

  Future<void> saveName() async {
    if (_isSaving) return;
    final error = validateRequired(_name, field: 'O nome');
    if (error != null) {
      _nameError = error;
      notifyListeners();
      return;
    }

    _isSaving = true;
    _nameError = null;
    notifyListeners();

    final result = await _users.updateProfile(
      name: _name,
      avatarUrl: _user?.avatarUrl,
    );
    if (await _handleUnauthorized(result)) return;

    switch (result) {
      case Ok(value: final user):
        _user = user;
        _savedMessage = 'Nome atualizado.';
      case Failure(error: ValidationError()):
        _nameError = 'Nome inválido.';
      case Failure(:final error):
        _nameError = error.message;
    }
    _isSaving = false;
    notifyListeners();
  }

  void onThemeModeChanged(ThemeMode mode) {
    _theme.select(mode);
    notifyListeners();
  }

  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    notifyListeners();
    // Mesmo se o servidor falhar, a sessão local já foi limpa pelo repositório.
    await _auth.logout();
    _coordinator.onLoggedOut();
  }

  Future<bool> _handleUnauthorized(Result<Object?> result) async {
    if (result.errorOrNull is! UnauthorizedError) return false;
    await _auth.logout();
    _coordinator.onSessionExpired();
    return true;
  }
}
