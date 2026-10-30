import 'package:flutter/material.dart';

/// Tema escolhido pelo usuário (claro, escuro ou do sistema).
///
/// Observer: o `MaterialApp` escuta este notifier e reconstrói com o novo
/// `themeMode`; a tela de perfil só chama [select]. Começa no claro, que é o
/// tema padrão do app.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.value = ThemeMode.light]);

  void select(ThemeMode mode) => value = mode;
}
