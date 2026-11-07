import 'package:flutter/material.dart';

import '../scenes/home/home_factory.dart';
import '../scenes/login/login_factory.dart';
import 'app_services.dart';

/// Decide a primeira tela: home se já houver sessão guardada, login caso contrário.
class StartupGate extends StatefulWidget {
  const StartupGate({required this.services, super.key});

  final AppServices services;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  late final Future<bool> _hasSession = widget.services.auth.restore().then(
    (result) => result.valueOrNull != null,
  );

  /// Montada uma única vez. Se o builder chamasse a Factory a cada rebuild,
  /// um hot reload criaria um ViewModel novo sem `load()`.
  Widget? _firstScene;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _firstScene ??= (snapshot.data ?? false)
            ? HomeFactory.make(widget.services)
            : LoginFactory.make(widget.services);
      },
    );
  }
}
