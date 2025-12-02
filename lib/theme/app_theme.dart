import 'package:flutter/material.dart';

class AppTheme {
  static const Color _warmPrimary = Color(0xFFBF7A30); // tierra / naranja suave
  static const Color _warmSecondary = Color(0xFF8A5A2B);
  static const Color _warmSurface = Color(0xFFFFFFFF);

  static ThemeData lightTheme() {
    final seed = _warmPrimary;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      primary: _warmPrimary,
      secondary: _warmSecondary,
      surface: _warmSurface,
      brightness: Brightness.light,
    );

    final textTheme = Typography.blackMountainView
        .apply(fontFamily: 'Poppins')
        .copyWith(
          titleLarge: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            color: Color(0xFF4A3020), // marrón oscuro para títulos
          ),
          bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFF4A3020)),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 6,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          backgroundColor: colorScheme.surface,
          side: BorderSide(
            color: colorScheme.onSurface.withAlpha((0.12 * 255).round()),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      // cardTheme intentionally omitted to keep defaults consistent
    );
  }
}
