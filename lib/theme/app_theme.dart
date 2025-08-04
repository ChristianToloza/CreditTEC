import 'package:flutter/material.dart';

class AppColors {
  static const Color lightBackgroundColor = Colors.white;
  static const Color lightTextColor = Color(0xFF212121);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightBorderColor = Color(0xFFD1D5DB);
  static const Color lightNavbarBackgroundColor = Color(0xFF155F82);
  static const Color lightNavbarTextColor = Colors.white;
  static const Color lightSidenavBackgroundColor = Color(0xFF155F82);
  static const Color lightSidenavTextColor = Colors.white;
  static const Color lightSidenavHoverBackgroundColor = Color(0xFF104C6B);

  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkTextColor = Color(0xFFF0F0F0);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkBorderColor = Color(0xFF424242);
  static const Color darkNavbarBackgroundColor = Color(0xFF2C3E50);
  static const Color darkNavbarTextColor = Color(0xFFECF0F1);
  static const Color darkSidenavBackgroundColor = Color(0xFF2C3E50);
  static const Color darkSidenavTextColor = Color(0xFFECF0F1);
  static const Color darkSidenavHoverBackgroundColor = Color(0xFF34495E);

  static const Color primaryColor = Color(0xFF155F82);
  static const Color accentColorLight = Color(0xFF155F82);
  static const Color accentColorDark = Color(0xFF2ECC71);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.lightBackgroundColor,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.accentColorLight,
      surface: AppColors.lightSurfaceColor,
      background: AppColors.lightBackgroundColor,
      error: Colors.red,
      onPrimary: AppColors.lightNavbarTextColor,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextColor,
      onBackground: AppColors.lightTextColor,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightNavbarBackgroundColor,
      foregroundColor: AppColors.lightNavbarTextColor,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.lightNavbarTextColor),
      titleTextStyle: TextStyle(
        color: AppColors.lightNavbarTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightTextColor),
      bodyMedium: TextStyle(color: AppColors.lightTextColor),
      titleLarge: TextStyle(color: AppColors.lightTextColor),
    ).apply(
      bodyColor: AppColors.lightTextColor,
      displayColor: AppColors.lightTextColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.lightNavbarTextColor,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.lightNavbarTextColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurfaceColor,
      hintStyle: TextStyle(color: AppColors.lightTextColor.withOpacity(0.6)),
      labelStyle: const TextStyle(color: AppColors.primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.lightBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.lightBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurfaceColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.lightBorderColor),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titleTextStyle: TextStyle(
        color: AppColors.lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: AppColors.lightTextColor,
        fontSize: 16,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.accentColorDark,
      surface: AppColors.darkSurfaceColor,
      background: AppColors.darkBackgroundColor,
      error: Colors.redAccent,
      onPrimary: AppColors.darkNavbarTextColor,
      onSecondary: AppColors.darkTextColor,
      onSurface: AppColors.darkTextColor,
      onBackground: AppColors.darkTextColor,
      onError: Colors.black,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkNavbarBackgroundColor,
      foregroundColor: AppColors.darkNavbarTextColor,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.darkNavbarTextColor),
      titleTextStyle: TextStyle(
        color: AppColors.darkNavbarTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkTextColor),
      bodyMedium: TextStyle(color: AppColors.darkTextColor),
      titleLarge: TextStyle(color: AppColors.darkTextColor),
    ).apply(
      bodyColor: AppColors.darkTextColor,
      displayColor: AppColors.darkTextColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.darkNavbarTextColor,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentColorDark,
      foregroundColor: AppColors.darkTextColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceColor,
      hintStyle: TextStyle(color: AppColors.darkTextColor.withOpacity(0.6)),
      labelStyle: const TextStyle(color: AppColors.accentColorDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.accentColorDark,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurfaceColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.darkBorderColor),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titleTextStyle: TextStyle(
        color: AppColors.darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: AppColors.darkTextColor, fontSize: 16),
    ),
  );
}
