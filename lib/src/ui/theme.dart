import 'package:material_ui/material_ui.dart';

import '../core/brand.dart';
import '../data/settings_store.dart';

const brandViolet = Color(Brand.violet);
const brandDeep = Color(Brand.violetDeep);
const brandNight = Color(Brand.violetNight);
const alertRed = Color(Brand.alert);
const alertDeep = Color(Brand.alertDeep);
const amber = Color(Brand.amber);

/// Tabular figures keep the stopwatch from jittering as digits change.
const tabular = [FontFeature.tabularFigures()];

ThemeMode toThemeMode(AppThemeMode m) => switch (m) {
  AppThemeMode.system => ThemeMode.system,
  AppThemeMode.light => ThemeMode.light,
  AppThemeMode.dark => ThemeMode.dark,
};

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: brandViolet,
    brightness: brightness,
  ).copyWith(primary: brightness == Brightness.light ? brandViolet : null);
  final base = ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    fontFamily: 'Inter',
    visualDensity: VisualDensity.standard,
  );
  final radius = BorderRadius.circular(18);
  return base.copyWith(
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xFFF8F6FD)
        : scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontFamily: 'Inter',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: brightness == Brightness.light
          ? Colors.white
          : scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: brightness == Brightness.light
          ? Colors.white
          : scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(
        base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      height: 68,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.light
          ? Colors.white
          : scheme.surfaceContainerHigh,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
