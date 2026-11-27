import 'package:design_system_ponto/design_system.dart';
import 'package:flutter/material.dart';

import 'app/app_services.dart';
import 'app/navigation.dart';
import 'app/startup_gate.dart';

void main() {
  runApp(CarteiraApp(services: AppServices.remote()));
}

class CarteiraApp extends StatelessWidget {
  const CarteiraApp({required this.services, super.key});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    // O tema vem do design system; o modo (claro, escuro, sistema) é
    // escolhido no perfil e começa no escuro.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: services.theme,
      builder: (context, mode, child) => MaterialApp(
        title: 'Carteira Digital',
        debugShowCheckedModeBanner: false,
        navigatorKey: appNavigatorKey,
        theme: DsTheme.light(),
        darkTheme: DsTheme.dark(),
        themeMode: mode,
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
        home: child,
      ),
      // Fora do builder: trocar o tema não recria o StartupGate.
      child: StartupGate(services: services),
    );
  }
}
