import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'app/app_services.dart';
import 'app/navigation.dart';
import 'app/startup_gate.dart';

void main() {
  // Licenças OFL das fontes do design system aparecem na tela de licenças.
  AppFonts.registerLicenses();
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
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
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
