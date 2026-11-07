import 'package:flutter/material.dart';

/// Chave global de navegação, usada pelos coordinators para trocar de tela.
final appNavigatorKey = GlobalKey<NavigatorState>();

/// Empilha [scene] e espera ela sair. A cena já vem montada pela Factory,
/// fora do builder da rota, pelo mesmo motivo do StartupGate.
Future<T?> pushScene<T>(Widget scene) =>
    appNavigatorKey.currentState?.push(
      MaterialPageRoute<T>(builder: (_) => scene),
    ) ??
    Future.value();

/// Troca a pilha inteira por [scene], sem permitir voltar.
void resetToScene(Widget scene) {
  appNavigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => scene),
    (_) => false,
  );
}

/// Fecha a cena do topo, devolvendo [result] para quem a abriu.
void popScene<T>([T? result]) => appNavigatorKey.currentState?.pop(result);
