import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'pages/buttons_page.dart';
import 'pages/forms_page.dart';
import 'pages/inputs_page.dart';
import 'pages/lists_page.dart';
import 'pages/prototypes_page.dart';
import 'pages/states_page.dart';
import 'pages/tokens_page.dart';
import 'widgets/menu_panel.dart';

void main() {
  AppFonts.registerLicenses();
  runApp(const GalleryApp());
}

/// Theme mode chosen in the gallery. A [ValueNotifier] is enough: one value,
/// one listener, no package.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.dark);

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'Galeria',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
        home: const GalleryHome(),
      ),
    );
  }
}

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});

  static const _pages = <GalleryEntry>[
    GalleryEntry(
      title: 'Tokens',
      icon: Icons.palette_rounded,
      page: TokensPage(),
    ),
    GalleryEntry(
      title: 'Botões',
      icon: Icons.smart_button_rounded,
      page: ButtonsPage(),
    ),
    GalleryEntry(title: 'Campos', icon: Icons.edit_rounded, page: InputsPage()),
    GalleryEntry(
      title: 'Listas',
      icon: Icons.list_alt_rounded,
      page: ListsPage(),
    ),
    GalleryEntry(
      title: 'Estados',
      icon: Icons.hourglass_empty_rounded,
      page: StatesPage(),
    ),
    GalleryEntry(
      title: 'Filtros e detalhes',
      icon: Icons.tune_rounded,
      page: FormsPage(),
    ),
    GalleryEntry(
      title: PrototypesPage.title,
      icon: Icons.phone_android_rounded,
      page: PrototypesPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Galeria',
      actions: const [ThemeModeButton()],
      padded: false,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: const [MenuPanel(entries: _pages)],
      ),
    );
  }
}

/// Cycles system -> light -> dark. Inside AppScaffold it becomes a 44px
/// round chrome button.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        final icon = switch (mode) {
          ThemeMode.system => Icons.brightness_auto_rounded,
          ThemeMode.light => Icons.light_mode_rounded,
          ThemeMode.dark => Icons.dark_mode_rounded,
        };
        return IconButton(
          tooltip: 'Tema: ${mode.name}',
          icon: Icon(icon),
          onPressed: () {
            themeMode.value = switch (mode) {
              ThemeMode.system => ThemeMode.light,
              ThemeMode.light => ThemeMode.dark,
              ThemeMode.dark => ThemeMode.system,
            };
          },
        );
      },
    );
  }
}
