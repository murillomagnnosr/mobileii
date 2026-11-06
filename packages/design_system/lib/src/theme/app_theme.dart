import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'app_effects.dart';
import 'app_semantic_colors.dart';

/// Builds the two [ThemeData] of the app from the tokens.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColorPalette p, Brightness brightness) {
    final e = AppEffects.fromPalette(p, brightness);
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      secondary: p.accent,
      onSecondary: p.onAccent,
      secondaryContainer: p.primaryContainer,
      onSecondaryContainer: p.onPrimaryContainer,
      tertiary: p.transfer,
      onTertiary: p.onKind,
      error: p.error,
      onError: p.onError,
      errorContainer: p.expenseContainer,
      onErrorContainer: p.error,
      surface: p.surface,
      onSurface: p.onSurface,
      onSurfaceVariant: p.onSurfaceMuted,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceVariant,
      surfaceContainerHighest: p.surfaceVariant,
      surfaceTint: Colors.transparent,
      outline: p.outline,
      outlineVariant: p.outlineVariant,
      inverseSurface: p.onSurface,
      onInverseSurface: p.surface,
      inversePrimary: p.primaryContainer,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final textTheme = AppTypography.textTheme.apply(
      bodyColor: p.onSurface,
      displayColor: p.onSurface,
    );

    // A transparent AppBar guesses the status-bar icon brightness wrong, so
    // the overlay style is always explicit.
    final overlayStyle =
        (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: color, width: width),
        );

    // Floating label and icons follow the field state: error, focus, rest.
    Color fieldStateColor(Set<WidgetState> states) {
      if (states.contains(WidgetState.error)) return p.error;
      if (states.contains(WidgetState.focused)) return p.primary;
      return p.onSurfaceMuted;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.sansFamily,
      package: AppTypography.fontPackage,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: textTheme,
      dividerColor: p.outlineVariant,
      splashFactory: InkSparkle.splashFactory,
      highlightColor: Colors.transparent,
      extensions: [AppSemanticColors.fromPalette(p), e],
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.primary,
        selectionColor: p.primary.withValues(alpha: 0.30),
        selectionHandleColor: p.primary,
      ),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const Icon(Icons.arrow_back_rounded),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(
            backgroundColor: p.background,
          ),
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.scrolledUnder)
              ? e.scrolledBar
              : Colors.transparent,
        ),
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: AppTypography.appBarTitle.copyWith(color: p.onSurface),
        iconTheme: IconThemeData(color: p.onSurface, size: 22),
        actionsIconTheme: IconThemeData(color: p.onSurface, size: 22),
        // 44px chrome circle inside a 48px tap box: 18 + 2 puts its edge on
        // the 20px screen gutter.
        actionsPadding: const EdgeInsets.only(right: AppSpacing.screen - 2),
        systemOverlayStyle: overlayStyle,
      ),
      cardTheme: CardThemeData(
        color: e.glass,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: e.glassBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? p.surfaceVariant : p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: inputBorder(p.outline),
        enabledBorder: inputBorder(p.outline),
        focusedBorder: inputBorder(p.primary, 2),
        errorBorder: inputBorder(p.error, 1.5),
        focusedErrorBorder: inputBorder(p.error, 2),
        disabledBorder: inputBorder(p.outlineVariant),
        labelStyle: AppTypography.bodyMedium.copyWith(color: p.onSurfaceMuted),
        hintStyle: AppTypography.bodyMedium.copyWith(color: p.onSurfaceMuted),
        // InputDecorator draws the floating label at 0.75x: 17px renders
        // at about 12.75px.
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (states) => AppTypography.weighted(
            AppTypography.bodyLarge,
            700,
          ).copyWith(color: fieldStateColor(states)),
        ),
        prefixIconColor: WidgetStateColor.resolveWith(fieldStateColor),
        suffixIconColor: WidgetStateColor.resolveWith(fieldStateColor),
        helperStyle: AppTypography.bodySmall.copyWith(color: p.onSurfaceMuted),
        errorStyle: AppTypography.weighted(
          AppTypography.bodySmall,
          600,
        ).copyWith(color: p.error),
        prefixStyle: AppTypography.weighted(
          AppTypography.bodyLarge,
          600,
        ).copyWith(color: p.onSurfaceMuted),
      ),
      // Global FilledButton stays SOLID: dialogs and ad-hoc buttons never
      // inherit the CTA gradient (AppButton paints that itself).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: AppTypography.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              minimumSize: const Size(64, 56),
              shape: const StadiumBorder(),
              side: BorderSide(color: p.outline, width: 1.5),
              foregroundColor: p.onSurface,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              textStyle: AppTypography.labelLarge,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return p.primary.withValues(alpha: 0.08);
                }
                if (states.contains(WidgetState.hovered)) {
                  return p.primary.withValues(alpha: 0.04);
                }
                return null;
              }),
            ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(48, 44),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      // Fallback when AppFab is not used.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        sizeConstraints: const BoxConstraints.tightFor(width: 60, height: 60),
        iconSize: 28,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: isDark ? p.surfaceVariant : p.onSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: isDark ? p.onSurface : p.surface,
        ),
        actionTextColor: isDark ? p.primary : p.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: isDark ? BorderSide(color: p.outlineVariant) : BorderSide.none,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 12,
        horizontalTitleGap: 16,
        minLeadingWidth: 44,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        iconColor: p.onSurfaceMuted,
        titleTextStyle: AppTypography.titleSmall.copyWith(color: p.onSurface),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: p.onSurfaceMuted,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.onPrimary : p.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.primary
              : p.surfaceVariant,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : p.outline,
        ),
        trackOutlineWidth: const WidgetStatePropertyAll(1.5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
          side: BorderSide(color: p.outlineVariant),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: p.onSurface,
          fontSize: 20,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: p.onSurfaceMuted,
        ),
        barrierColor: isDark
            ? const Color(0xB8070A1A)
            : const Color(0x6615132E),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.outline,
        dragHandleSize: const Size(40, 5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: e.glass,
        indicatorColor: p.primaryContainer,
        indicatorShape: const StadiumBorder(),
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.labelMedium.copyWith(fontSize: 12, color: p.onSurface),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
        color: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.primary : p.surface,
        ),
        side: WidgetStateBorderSide.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? BorderSide(color: p.primary)
              : BorderSide(color: p.outline),
        ),
        labelStyle: AppTypography.labelLarge.copyWith(
          fontSize: 14,
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? p.onPrimary
                : p.onSurface,
          ),
        ),
        showCheckmark: false,
        elevation: 2,
        pressElevation: 2,
        shadowColor: Colors.transparent,
        selectedShadowColor: p.primary.withValues(alpha: 0.60),
        surfaceTintColor: Colors.transparent,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: p.onSurfaceMuted,
          selectedBackgroundColor: p.primary,
          selectedForegroundColor: p.onPrimary,
          side: BorderSide(color: p.outline),
          shape: const StadiumBorder(),
          minimumSize: const Size(0, 52),
          textStyle: AppTypography.labelLarge,
        ).copyWith(iconSize: const WidgetStatePropertyAll(20)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.surfaceVariant,
        circularTrackColor: p.surfaceVariant,
        linearMinHeight: 6,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        headerForegroundColor: p.onSurface,
        todayBorder: BorderSide(color: p.primary),
      ),
      // iconButtonTheme is NOT set globally: AppScaffold styles the chrome
      // buttons of its app bar.
    );
  }
}
