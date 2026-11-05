import 'package:flutter/material.dart';

/// Semantic color tokens for the prototype UI.
///
/// Screens consume these tokens, or the Material [ColorScheme] built from
/// them, instead of declaring their own color literals. Keeping the palette in
/// one place is what `docs/ARCHITECTURE.md` requires.
///
/// The palette is the soft "speech bubble" system taken from the client's home
/// screen mockup: cream canvas, sky band, navy ink, and a blue primary family.
/// Green and red stay reserved for status so an open or closed place never
/// blends into the theme.
abstract final class AppColors {
  // Foundations.
  static const background = Color(0xFFFBF8F4);
  static const sky = Color(0xFFDFEDFB);
  static const ink = Color(0xFF1F2A5C);
  static const inkStrong = Color(0xFF0B1F4B);

  // Primary family.
  //
  // [primary] is the interactive blue: white on it clears 4.5:1 at normal text
  // sizes. [brand] is the lighter hero blue and is only safe for large bold
  // text on white or for navy text, so controls use [primary] instead.
  static const primary = Color(0xFF1F6FD1);
  static const onPrimary = Color(0xFFFFFFFF);
  static const brand = Color(0xFF3490F5);
  static const onBrand = Color(0xFF0B1F4B);
  static const bubble = Color(0xFFBBDDFF);
  static const surface = Color(0xFFE9F2F9);
  static const bubbleUnder = Color(0xFF8EC4FA);
  static const surfaceUnder = Color(0xFFC3D8E8);
  static const raised = Color(0xFFFFFFFF);

  // Accent and status.
  static const accent = Color(0xFFE2A92B);
  static const open = Color(0xFF14594A);
  static const onOpen = Color(0xFFFFFFFF);
  static const error = Color(0xFFB3261E);
  static const onError = Color(0xFFFFFFFF);
  static const demoContainer = Color(0xFFFBEBC8);
  static const onDemoContainer = Color(0xFF6A4B00);

  // Quiet text and dividers.
  static const mutedInk = Color(0xFF5A6485);
  static const outline = Color(0xFFDCE6F2);
  static const outlineStrong = Color(0xFFC3D8E8);

  // Illustration-only tints for the home screen. They are decorative and carry
  // no meaning on their own.
  static const pin = Color(0xFF2F8AF3);
  static const faceHappy = Color(0xFFBBDDFF);
  static const faceSad = Color(0xFF9DCBF5);
  static const faceGood = Color(0xFF2F7EF0);
  static const faceFeature = Color(0xFF2B6BC9);
  static const infoBubble = Color(0xFFDCEBFF);
  static const footerPill = Color(0xFFC9DAEA);

  // Map and media.
  static const map = Color(0xFFE8EEF6);
  static const road = Color(0xFFFFFEFA);
  static const scrim = Color(0x8A0B1F4B);
  static const onScrim = Color(0xFFFFFFFF);
  static const viewerBackground = Color(0xFF0B1F4B);

  // Category tints for the no-photo placeholder. Every tint stays in the blue
  // family so the palette reads as one system, while the lightness still gives
  // each category a distinct placeholder.
  static const tambayanTint = Color(0xFFE9F2F9);
  static const coffeeTint = Color(0xFFDCEBFF);
  static const parkTint = Color(0xFFCFE4F6);
  static const eateryTint = Color(0xFFE4EDF7);
  static const otherTint = Color(0xFFDCE6F1);
}

/// Hard underside offsets used by the bubble shapes and cards.
///
/// These are logical pixels; callers scale them with the surface they paint.
const double kCardUnderOffset = 5;

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.bubble,
    onPrimaryContainer: AppColors.inkStrong,
    secondary: AppColors.brand,
    onSecondary: AppColors.onBrand,
    secondaryContainer: AppColors.surface,
    onSecondaryContainer: AppColors.ink,
    tertiary: AppColors.accent,
    onTertiary: AppColors.inkStrong,
    tertiaryContainer: AppColors.demoContainer,
    onTertiaryContainer: AppColors.onDemoContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    surface: AppColors.background,
    onSurface: AppColors.ink,
    surfaceContainerHighest: AppColors.sky,
    surfaceContainerHigh: AppColors.surface,
    surfaceContainerLow: AppColors.raised,
    outline: AppColors.outlineStrong,
    outlineVariant: AppColors.outline,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Nunito',
  );

  TextStyle display(double size, {FontWeight weight = FontWeight.w600}) {
    return TextStyle(
      fontFamily: 'Fredoka',
      fontSize: size,
      fontWeight: weight,
      color: AppColors.inkStrong,
      height: 1.12,
      letterSpacing: 0.2,
    );
  }

  final textTheme = base.textTheme.copyWith(
    displayLarge: display(46, weight: FontWeight.w700),
    displayMedium: display(38, weight: FontWeight.w700),
    displaySmall: display(32),
    headlineLarge: display(30),
    headlineMedium: display(27),
    headlineSmall: display(24),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
      letterSpacing: 0,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    ),
    titleSmall: base.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      fontSize: 16,
      height: 1.45,
      color: AppColors.ink,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      height: 1.45,
      color: AppColors.ink,
    ),
    bodySmall: base.textTheme.bodySmall?.copyWith(
      fontSize: 13,
      height: 1.4,
      color: AppColors.mutedInk,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    labelMedium: base.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    labelSmall: base.textTheme.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
      color: AppColors.ink,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: display(24),
      contentTextStyle: textTheme.bodyMedium,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.outlineStrong),
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.raised,
      hintStyle: const TextStyle(color: AppColors.mutedInk),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.raised,
      selectedColor: AppColors.bubble,
      surfaceTintColor: Colors.transparent,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: const TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
      secondaryLabelStyle: const TextStyle(
        color: AppColors.inkStrong,
        fontWeight: FontWeight.w800,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return selected ? AppColors.primary : AppColors.raised;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return selected ? AppColors.onPrimary : AppColors.ink;
        }),
        side: const WidgetStatePropertyAll(BorderSide.none),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
        ),
      ),
    ),
    dividerColor: AppColors.outline,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.inkStrong,
      contentTextStyle: TextStyle(
        fontFamily: 'Nunito',
        color: AppColors.onScrim,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
