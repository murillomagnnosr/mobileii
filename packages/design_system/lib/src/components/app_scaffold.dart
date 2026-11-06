import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_effects.dart';
import '../tokens/app_spacing.dart';
import 'app_backdrop.dart';
import 'app_logo_mark.dart';
import 'gap.dart';

/// Scaffold with the app's standard chrome: the aurora [AppBackdrop], a
/// transparent app bar with 44px round chrome buttons, and horizontal screen
/// padding around [body] (unless [padded] is false, for full-bleed lists).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.floatingActionButton,
    this.padded = true,
    this.showAppBar = true,
    this.spotlight = false,
    this.brand = false,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;

  /// Rendered below the body, e.g. a [NavigationBar].
  final Widget? bottom;
  final Widget? floatingActionButton;
  final bool padded;
  final bool showAppBar;

  /// Adds the Login spotlight to the backdrop.
  final bool spotlight;

  /// Shows the 28px [AppLogoMark] before the title (Home).
  final bool brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final e = context.effects;

    Widget? titleWidget;
    if (title != null) {
      titleWidget = brand
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogoMark(size: 28),
                const Gap(10),
                Flexible(child: Text(title!, overflow: TextOverflow.ellipsis)),
              ],
            )
          : Text(title!);
    }

    // The back button's 44px circle and the title sit on the screen gutter
    // instead of in Flutter's default 56px leading slot.
    final hasLeading =
        leading != null ||
        (ModalRoute.of(context)?.impliesAppBarDismissal ?? false);

    Widget content = padded
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: body,
          )
        : body;
    if (floatingActionButton != null) content = _FabFade(child: content);

    final scaffold = Stack(
      fit: StackFit.expand,
      children: [
        AppBackdrop(spotlight: spotlight),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: showAppBar
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  // Chrome buttons (back, edit, theme toggle) become round
                  // tonal buttons. An action that must not look like chrome
                  // passes its own style.
                  child: IconButtonTheme(
                    data: IconButtonThemeData(
                      style: IconButton.styleFrom(
                        fixedSize: const Size.square(44),
                        shape: const CircleBorder(),
                        backgroundColor: e.chromeFill,
                        foregroundColor: scheme.onSurface,
                        side: BorderSide(color: scheme.outlineVariant),
                        iconSize: 22,
                      ),
                    ),
                    child: AppBar(
                      toolbarHeight: 64,
                      title: titleWidget,
                      actions: actions,
                      leading: leading,
                      // 48px tap box centred in 84: the circle spans 20–64.
                      leadingWidth: AppSpacing.screen * 2 + 44,
                      titleSpacing: hasLeading ? 0 : AppSpacing.screen,
                    ),
                  ),
                )
              : null,
          // Lists scroll behind the gesture bar instead of being cut at the
          // inset; a ListView without explicit padding still adds the inset
          // itself, and the ones with padding add it by hand.
          body: SafeArea(bottom: false, child: content),
          bottomNavigationBar: bottom,
          floatingActionButton: floatingActionButton == null
              ? null
              : Padding(
                  // Scaffold keeps the FAB 16px from the edge; 4 more puts it
                  // on the 20px gutter like the cards.
                  padding: const EdgeInsets.only(
                    right: AppSpacing.screen - kFloatingActionButtonMargin,
                  ),
                  child: floatingActionButton,
                ),
        ),
      ],
    );

    if (showAppBar) return scaffold;
    // Without an AppBar nobody sets the status-bar icons: reuse the theme's.
    final overlay = theme.appBarTheme.systemOverlayStyle;
    if (overlay == null) return scaffold;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: scaffold,
    );
  }
}

/// Fades the bottom of the body under the floating action button, so a row
/// resting behind it fades out instead of showing a figure cut in half.
/// Lists keep [AppSpacing.fabClearance] at the end, so the last row always
/// scrolls clear of the fade.
class _FabFade extends StatelessWidget {
  const _FabFade({required this.child});

  /// FAB size (60) plus its margin (16) and a little air.
  static const double _height = 88;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fade = _height + MediaQuery.paddingOf(context).bottom;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) {
        final start = rect.height <= fade ? 0.0 : 1 - fade / rect.height;
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.black,
            Colors.black.withValues(alpha: 0),
          ],
          stops: [0, start, 1],
        ).createShader(rect);
      },
      child: child,
    );
  }
}
