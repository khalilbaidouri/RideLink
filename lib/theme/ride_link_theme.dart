import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideLinkTheme {
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF005127),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF1B6B3A),
    onPrimaryContainer: Color(0xFF9AE9AB),
    secondary: Color(0xFF835500),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFEAE2C),
    onSecondaryContainer: Color(0xFF6B4500),
    tertiary: Color(0xFF394565),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF515D7E),
    onTertiaryContainer: Color(0xFFCBD7FD),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFF7FAF3),
    onSurface: Color(0xFF181D18),
    surfaceContainerHighest: Color(0xFFE0E4DD),
    onSurfaceVariant: Color(0xFF404940),
    outline: Color(0xFF707A6F),
    outlineVariant: Color(0xFFBFC9BD),
    shadow: Color(0x14005127),
    scrim: Color(0x33000000),
    inverseSurface: Color(0xFF2D322D),
    onInverseSurface: Color(0xFFEEF2EB),
    inversePrimary: Color(0xFF8AD89C),
    surfaceTint: Color(0xFF1C6C3B),
  );

  static TextTheme _textTheme(ColorScheme colors) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base
        .copyWith(
          headlineLarge: base.headlineLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.64,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.33,
            letterSpacing: -0.24,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.56,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.43,
            letterSpacing: 0.14,
          ),
          labelMedium: base.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.33,
          ),
        )
        .apply(bodyColor: colors.onSurface, displayColor: colors.onSurface);
  }

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    textTheme: _textTheme(lightColorScheme),
    scaffoldBackgroundColor: lightColorScheme.surface,

    // 🔴 FIX 1 : CardThemeData OK pour ton CI
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFFFF),
      elevation: 2,
      shadowColor: lightColorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5ED),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColorScheme.secondary,
        foregroundColor: lightColorScheme.onSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightColorScheme.primary,
        side: BorderSide(color: lightColorScheme.outline),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightColorScheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // 🔴 FIX 2
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return lightColorScheme.primary;
        }
        return lightColorScheme.surfaceContainerHighest;
      }),
      checkColor: MaterialStateProperty.all(
        lightColorScheme.onPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightColorScheme.inverseSurface,
      contentTextStyle: TextStyle(
        color: lightColorScheme.onInverseSurface,
      ),
    ),
  );
}
