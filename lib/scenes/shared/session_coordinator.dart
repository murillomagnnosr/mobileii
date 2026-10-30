/// Parte comum dos coordinators das cenas autenticadas.
abstract interface class SessionCoordinator {
  /// Sessão ausente, inválida ou expirada: volta ao login sem permitir
  /// voltar.
  void onSessionExpired();
}
