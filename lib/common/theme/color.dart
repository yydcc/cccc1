import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalThemData {
  // 定义主题色
  static const Color primaryColor = Color(0xFF2196F3);  // 主色调
  static const Color secondaryColor = Color(0xFF42A5F5); // 次要色调
  static const Color accentColor = Colors.deepOrange;   // 强调色
  static const Color backgroundColor = Color(0xFFF5F5F5); // 背景色
  static const Color textPrimaryColor = Color(0xFF333333); // 主文本色
  static const Color textSecondaryColor = Color(0xFF666666); // 次要文本色
  static const Color textTertiaryColor = Color(0xFF999999);  // 添加这一行
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

  // 主题色配置
  static final Map<String, ThemeData> themes = {
    'blue': _blueTheme,
    'green': _greenTheme,
    'orange': _orangeTheme,
    'black': _blackTheme,
  };

  // 蓝色主题
  static final ThemeData _blueTheme = ThemeData(
    primaryColor: Color(0xFF2196F3),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF42A5F5),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textSecondaryColor),
    ),
    dividerColor: dividerColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF2196F3),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2196F3),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF2196F3),
      unselectedItemColor: textSecondaryColor,
    ),
  );

  // 绿色主题
  static final ThemeData _greenTheme = ThemeData(
    primaryColor: Color(0xFF4CAF50),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF4CAF50),
      secondary: Color(0xFF81C784),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textSecondaryColor),
    ),
    dividerColor: dividerColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF4CAF50),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF4CAF50),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF4CAF50),
      unselectedItemColor: textSecondaryColor,
    ),
  );

  static final ThemeData _orangeTheme = ThemeData(
    primaryColor: Color(0xFFFF9800),
    colorScheme: ColorScheme.light(
      primary: Color(0xFFFF9800),
      secondary: Color(0xFFFFC107),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textSecondaryColor),
    ),
    dividerColor: dividerColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFFFF9800),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFFF9800),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFFFF9800),
      unselectedItemColor: textSecondaryColor,
    ),
  );

  // 黑色主题
  static final ThemeData _blackTheme = ThemeData(
    primaryColor: Colors.black,
    colorScheme: ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.grey,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
    dividerColor: Colors.grey,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
  );

  static final Rx<ThemeData> currentTheme = _blueTheme.obs;

  // 初始化主题
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme') ?? 'blue';
    currentTheme.value = themes[themeName] ?? _blueTheme;
  }

  // 切换主题
  static Future<void> changeTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeName);
    currentTheme.value = themes[themeName] ?? _blueTheme;
  }

  // 获取主题名称
  static String getCurrentThemeName() {
    if (currentTheme.value == _blueTheme) return 'blue';
    if (currentTheme.value == _greenTheme) return 'green';
    if (currentTheme.value == _blackTheme) return 'black';
    if (currentTheme.value ==  _orangeTheme) return 'orange';
    return 'blue';
  }
}
