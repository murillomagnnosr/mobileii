import 'package:carteira_core/carteira_core.dart';

import 'api_config.dart';
import 'session_store.dart';
import 'theme_controller.dart';

/// Repositórios do app, montados uma vez na inicialização e injetados nas
/// cenas pelas Factories. Trocar a implementação (remota, em memória, teste)
/// acontece aqui e em nenhum outro lugar.
class AppServices {
  AppServices({
    required this.auth,
    required this.users,
    required this.transactions,
    ThemeController? theme,
  }) : theme = theme ?? ThemeController();

  /// Monta os repositórios remotos, falando com a API configurada em [ApiConfig].
  factory AppServices.remote() {
    final client = ApiClient(baseUrl: ApiConfig.baseUrl);
    final storage = SharedPrefsSessionStorage();
    return AppServices(
      auth: RemoteAuthRepository(client: client, storage: storage),
      users: RemoteUserRepository(client: client),
      transactions: RemoteTransactionRepository(client: client),
    );
  }

  final AuthRepository auth;
  final UserRepository users;
  final TransactionRepository transactions;

  /// Tema claro/escuro escolhido no perfil.
  final ThemeController theme;
}
