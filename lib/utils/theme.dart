import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF215E8C);
  static const Color primaryWhite = Colors.white;
  static const Color primaryBlack = Colors.black;

  static ThemeData lightTheme = ThemeData(
    primarySwatch: MaterialColor(0xFF215E8C, {
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF215E8C),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    }),
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: primaryWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: primaryWhite,
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: primaryBlack, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: primaryBlack, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: primaryBlack, fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: primaryBlack, fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: primaryBlack, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: primaryBlack, fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: primaryBlack, fontSize: 16),
      bodyMedium: TextStyle(color: primaryBlack, fontSize: 14),
      bodySmall: TextStyle(color: primaryBlack, fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: primaryWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryBlue,
      surface: primaryWhite,
      background: primaryWhite,
      error: Colors.red,
      onPrimary: primaryWhite,
      onSecondary: primaryWhite,
      onSurface: primaryBlack,
      onBackground: primaryBlack,
      onError: primaryWhite,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: MaterialColor(0xFF215E8C, {
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF215E8C),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    }),
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: primaryBlack,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlack,
      foregroundColor: primaryWhite,
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: primaryWhite, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: primaryWhite, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: primaryWhite, fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: primaryWhite, fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: primaryWhite, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: primaryWhite, fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: primaryWhite, fontSize: 16),
      bodyMedium: TextStyle(color: primaryWhite, fontSize: 14),
      bodySmall: TextStyle(color: primaryWhite, fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: primaryWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: primaryBlue,
      secondary: primaryBlue,
      surface: Color(0xFF1E1E1E),
      background: primaryBlack,
      error: Colors.red,
      onPrimary: primaryWhite,
      onSecondary: primaryWhite,
      onSurface: primaryWhite,
      onBackground: primaryWhite,
      onError: primaryWhite,
    ),
  );
}

