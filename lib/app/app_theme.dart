import 'package:flutter/material.dart';

/// Semantic color tokens for the prototype UI.
///
/// Screens consume these tokens, or the Material [ColorScheme] built from
/// them, instead of declaring their own color literals. Keeping the palette in
/// one place is what `docs/ARCHITECTURE.md` requires and what lets the
/// provisional palette be replaced without hunting through widgets.
abstract final class AppColors {
  static const primary = Color(0xFF215B50);
  static const onPrimary = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F5EF);
  static const surface = Color(0xFFFFFFFF);
  static const sage = Color(0xFFE7EEE8);
  static const terracotta = Color(0xFFB4543A);
  static const ink = Color(0xFF252B28);
  static const mutedInk = Color(0xFF5C6862);
  static const outline = Color(0xFFE8E8E1);
  static const outlineStrong = Color(0xFFE0E5DF);

  /// Demo/status surfaces. [onDemoContainer] is deliberately darker than
  /// [terracotta] so the small uppercase banner text clears 4.5:1.
  static const demoContainer = Color(0xFFFFEDE4);
  static const onDemoContainer = Color(0xFFA8452C);

  static const map = Color(0xFFE8E8D9);
  static const road = Color(0xFFFFFEFA);

  /// Overlays sit on arbitrary photography, so they stay achromatic.
  static const scrim = Color(0x8A000000);
  static const onScrim = Color(0xFFFFFFFF);
  static const viewerBackground = Color(0xFF000000);

  /// Category tints for the no-photo placeholder.
  static const coffeeTint = Color(0xFFF2E5D6);
  static const parkTint = Color(0xFFE1EDDF);
  static const eateryTint = Color(0xFFF4E4DB);
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.background,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.terracotta,
        onSurface: AppColors.ink,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineStrong,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.secondaryContainer,
      shape: const StadiumBorder(),
      side: const BorderSide(color: AppColors.outlineStrong),
      selectedColor: AppColors.sage,
      labelStyle: TextStyle(
        color: scheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
