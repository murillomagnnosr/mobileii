import 'package:flutter/foundation.dart';

/// Endereço do servidor da API Carteira (mock do curso ou servidor real).
abstract final class ApiConfig {
  static String get baseUrl {
    // No emulador Android, localhost aponta para o próprio emulador.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }
}
