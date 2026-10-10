import 'package:carteira_design_system/carteira_design_system.dart';
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
    return MaterialApp(
      title: 'Carteira Digital',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Tema fixo claro, igual em todas as plataformas (Android, Web, Windows).
      themeMode: ThemeMode.light,
      home: StartupGate(services: services),
    );
  }
}
