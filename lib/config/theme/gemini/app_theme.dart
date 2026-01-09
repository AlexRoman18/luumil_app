import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color seedColor = Color(0xFF1E1C36);

class AppTheme {
  final bool isDarkmode;

  AppTheme({required this.isDarkmode});

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,
    brightness: isDarkmode ? Brightness.dark : Brightness.light,

    listTileTheme: const ListTileThemeData(iconColor: seedColor),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1C36),
      surfaceTintColor: Colors.transparent,
    ),
  );

  static setSistemUIOverlayStyle({required bool isDarkmode}) {
    final themeBrightness = isDarkmode ? Brightness.dark : Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: themeBrightness,
        statusBarIconBrightness: themeBrightness,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: themeBrightness,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }
}
