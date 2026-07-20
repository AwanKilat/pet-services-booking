import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Colors.orange;
  static const Color bg = Colors.white;
  static const Color card = Color(0xFFF5F5F5);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );
}
