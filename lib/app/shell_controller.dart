import 'package:flutter/foundation.dart';

/// Abas do app, na ordem da barra de navegação.
enum ShellTab { home, statement, insights, profile }

/// Aba aberta no shell.
///
/// Observer: o `ShellView` escuta este notifier e troca o conteúdo; as cenas
/// (pelos coordinators) só chamam [select], sem conhecer a barra.
class ShellController extends ValueNotifier<ShellTab> {
  ShellController([super.value = ShellTab.home]);

  void select(ShellTab tab) => value = tab;
}
