import 'package:flutter/material.dart';

/// Sistema de dise\u00f1o moderno y minimalista para Luumil App
class AppColors {
  // Colores primarios
  static const primary = Color(0xFF2196F3); // Azul moderno
  static const primaryDark = Color(0xFF1976D2);
  static const primaryLight = Color(0xFF64B5F6);

  // Colores de acento
  static const accent = Color(0xFF00BCD4); // Cyan
  static const success = Color(0xFF4CAF50); // Verde
  static const warning = Color(0xFFFFC107); // Amarillo
  static const error = Color(0xFFF44336); // Rojo

  // Neutrales
  static const background = Color(0xFFFAFAFA);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFF5F5F5);

  // Textos
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);

  // Bordes y divisores
  static const divider = Color(0xFFE0E0E0);
  static const border = Color(0xFFEEEEEE);

  // Gradientes
  static const gradientStart = primary;
  static const gradientEnd = accent;

  // Sombras
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Espaciados consistentes
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Bordes redondeados
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 9999.0;
}

/// Tipograf\u00eda
class AppTypography {
  static const String fontFamily = 'Poppins';

  // Tama\u00f1os
  static const double textXs = 12.0;
  static const double textSm = 14.0;
  static const double textBase = 16.0;
  static const double textLg = 18.0;
  static const double textXl = 20.0;
  static const double text2xl = 24.0;
  static const double text3xl = 30.0;
  static const double text4xl = 36.0;
}
