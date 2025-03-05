import 'dart:ui';

import 'package:flutter/material.dart';

class GlobalThemData {
  // 定义主题色
  static const Color primaryColor = Color(0xFF2196F3);  // 主色调
  static const Color secondaryColor = Colors.black; // 次要色调
  static const Color accentColor = Colors.deepOrange;   // 强调色
  static const Color backgroundColor = Color(0xFFF5F5F5); // 背景色
  static const Color textPrimaryColor = Color(0xFF333333); // 主文本色
  static const Color textSecondaryColor = Color(0xFF666666); // 次要文本色
  static const Color dividerColor = Color(0xFFEEEEEE);  // 分割线颜色

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightThemeData = themeData(lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkColorScheme, _darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      focusColor: focusColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      dividerColor: dividerColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: primaryColor,
    onPrimary: Colors.white,
    secondary: secondaryColor,
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
    background: backgroundColor,
    onBackground: textPrimaryColor,
    surface: Colors.white,
    onSurface: textPrimaryColor,
    brightness: Brightness.light,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: primaryColor,
    onPrimary: Colors.white,
    secondary: secondaryColor,
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
    background: Color(0xFF121212),
    onBackground: Colors.white,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    brightness: Brightness.dark,
  );
}
