import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryAppBarColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.defaultBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryAppBarColor,
        foregroundColor: AppColors.whiteAppBarTextColor,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButtonColor,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: GoogleFonts.notoSansKrTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.black,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: AppColors.grey7,
          ),
        ),
      ),
    );
  }
}