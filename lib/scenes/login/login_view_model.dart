import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

import 'login_coordinator.dart';

/// Estado e ações da cena de login.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._auth, required this._coordinator});

  final AuthRepository _auth;
  final LoginCoordinator _coordinator;

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void onEmailChanged(String value) {
    _email = value;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    _password = value;
    notifyListeners();
  }

  Future<void> submit() async {
    if (_isLoading) return;

    final email = _email.trim();
    if (email.isEmpty || _password.isEmpty) {
      _errorMessage = 'Informe e-mail e senha.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _auth.login(email: email, password: _password);

    // O repositório nunca lança: a falha vem como Failure com mensagem pronta.
    if (result case Failure(:final error)) {
      _isLoading = false;
      _errorMessage = error.message;
      notifyListeners();
      return;
    }

    // Sucesso: a tela de login sai da árvore, então não notifica mais.
    _isLoading = false;
    _coordinator.onLoginSuccess();
  }
}
