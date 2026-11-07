import 'dart:convert';

import 'package:carteira_core/carteira_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda a sessão entre execuções do app, em `shared_preferences`.
class SharedPrefsSessionStorage implements SessionStorage {
  static const _key = 'carteira.session';

  @override
  Future<Session?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      return Session.fromJson(asJson(jsonDecode(raw)));
    } catch (_) {
      // Sessão corrompida não deve travar o app: trata como deslogado.
      return null;
    }
  }

  @override
  Future<void> write(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
