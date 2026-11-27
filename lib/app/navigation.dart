import 'package:flutter/material.dart';

/// Chave global de navegação, usada pelos coordinators para trocar de tela.
final appNavigatorKey = GlobalKey<NavigatorState>();

/// Rota das cenas: a nova tela aparece com fade e sobe um pouco; ao voltar,
/// faz o caminho inverso. Respeita "remover animações" do aparelho.
class SceneRoute<T> extends PageRouteBuilder<T> {
  SceneRoute(Widget scene)
    : super(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) => scene,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}

/// Empilha [scene] e espera ela sair. A cena já vem montada pela Factory,
/// fora do builder da rota, pelo mesmo motivo do StartupGate.
Future<T?> pushScene<T>(Widget scene) =>
    appNavigatorKey.currentState?.push(SceneRoute<T>(scene)) ?? Future.value();

/// Troca a pilha inteira por [scene], sem permitir voltar.
void resetToScene(Widget scene) {
  appNavigatorKey.currentState?.pushAndRemoveUntil(
    SceneRoute<void>(scene),
    (_) => false,
  );
}

/// Fecha a cena do topo, devolvendo [result] para quem a abriu.
void popScene<T>([T? result]) => appNavigatorKey.currentState?.pop(result);
