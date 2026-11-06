import 'package:flutter/material.dart';

/// Tema escolhido pelo usuário (claro, escuro ou do sistema).
///
/// Observer: o `MaterialApp` escuta este notifier e reconstrói com o novo
/// `themeMode`; a tela de perfil só chama [select]. Começa no escuro no app
/// (`AppServices.remote()`); o padrão do controller é claro.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.value = ThemeMode.light]);

  void select(ThemeMode mode) => value = mode;
}
