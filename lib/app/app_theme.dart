import 'package:flutter/material.dart';

/// Semantic color tokens for the prototype UI.
///
/// Screens consume these tokens, or the Material [ColorScheme] built from
/// them, instead of declaring their own color literals. Keeping the palette in
/// one place is what `docs/ARCHITECTURE.md` requires and what lets the
/// provisional palette be replaced without hunting through widgets.
///
/// Warm Campus palette (see `docs/MVP_PLAN.md`): a warm cream canvas, a deep
/// teal-green for primary actions, and restrained campus-blue selection
/// states. The mango accent is reserved for small highlights.
abstract final class AppColors {
  static const primary = Color(0xFF14594A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const background = Color(0xFFFBF7EE);
  static const surface = Color(0xFFFFFFFF);
  static const sage = Color(0xFFE3EFE8);
  static const terracotta = Color(0xFFA8452C);
  static const campusBlue = Color(0xFF24558A);
  static const campusBlueContainer = Color(0xFFE8F0F8);
  static const onCampusBlueContainer = Color(0xFF173A5B);
  static const ink = Color(0xFF1C2320);
  static const mutedInk = Color(0xFF57675F);
  static const outline = Color(0xFFE7E2D5);
  static const outlineStrong = Color(0xFFE0DACB);

  /// Demo/status surfaces. [onDemoContainer] clears 4.5:1 on the tinted
  /// container, which the previous pair did not.
  static const demoContainer = Color(0xFFFFF1E7);
  static const onDemoContainer = terracotta;

  /// Small highlight for the app emblem and campus map marker outlines.
  static const accent = Color(0xFFF2B23E);

  static const map = Color(0xFFE8E8D9);
  static const road = Color(0xFFFFFEFA);

  /// Overlays sit on arbitrary photography, so they stay achromatic.
  static const scrim = Color(0x8A000000);
  static const onScrim = Color(0xFFFFFFFF);
  static const viewerBackground = Color(0xFF000000);

  /// Category tints for the no-photo placeholder. Tambayan reuses [sage].
  /// Kept distinct from each other so the placeholder still hints at the
  /// category, but every tint carries the same primary-colored icon.
  static const coffeeTint = Color(0xFFF3E7D7);
  static const parkTint = Color(0xFFE1EDDF);
  static const eateryTint = Color(0xFFF6E6DC);
  static const otherTint = Color(0xFFE6EAF1);
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
        tertiary: AppColors.campusBlue,
        onTertiary: AppColors.onPrimary,
        tertiaryContainer: AppColors.campusBlueContainer,
        onTertiaryContainer: AppColors.onCampusBlueContainer,
        onSurface: AppColors.ink,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineStrong,
      );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
  );

  final textTheme = base.textTheme.copyWith(
    headlineSmall: base.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.4,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    titleSmall: base.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
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
      selectedColor: AppColors.campusBlueContainer,
      labelStyle: TextStyle(
        color: scheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.campusBlueContainer,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.campusBlue : AppColors.mutedInk,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.campusBlue : AppColors.mutedInk,
        );
      }),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return selected ? AppColors.campusBlue : AppColors.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return selected ? AppColors.onPrimary : AppColors.ink;
        }),
        side: WidgetStateProperty.resolveWith(
          (states) => const BorderSide(color: AppColors.outlineStrong),
        ),
      ),
    ),
  );
}
