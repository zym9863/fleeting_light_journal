import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6200EE); // 紫色
  static const Color accentColor = Color(0xFF03DAC6); // 青色
  static const Color backgroundColor = Color(0xFFF5F5F5); // 浅灰色背景
  static const Color cardColor = Colors.white; // 卡片背景色
  static const Color textColor = Color(0xFF212121); // 主要文本颜色
  static const Color lightTextColor = Color(0xFF757575); // 次要文本颜色

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    hintColor: accentColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    appBarTheme: const AppBarTheme(
      color: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12.0,
        color: lightTextColor,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple).copyWith(secondary: accentColor),
  );
}
