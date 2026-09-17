// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  // 1. STANDARD OLED TACTICAL (Dark Mode)
  static ThemeData get tacticalTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.canvasBlack,
      primaryColor: AppColors.polarCyan,
      splashColor: AppColors.polarCyan.withOpacity(0.1),
      highlightColor: Colors.transparent,

      cardTheme: const CardTheme(
        color: AppColors.surfaceObsidian,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.borderHairline, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borderHairline, thickness: 1, space: 1),
      textTheme: const TextTheme(
        bodyMedium: AppTypography.body,
        titleLarge: AppTypography.headingPrimary,
      ),
    );
  }

  // 2. HIGH-ALBEDO SNOW BLINDNESS (Brutalist Light Mode)
  static ThemeData get highAlbedoTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Pure glaring white
      primaryColor: const Color(0xFF000000), // Pitch black interactions
      splashColor: Colors.black12,
      highlightColor: Colors.transparent,

      cardTheme: const CardTheme(
        color: Color(0xFFF1F5F9), // Very light gray to distinguish from background
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: Color(0xFF000000), width: 2), // Thick brutalist black borders
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF000000), thickness: 2, space: 1),
      
      // Override text colors to pure black for maximum contrast
      textTheme: TextTheme(
        bodyMedium: AppTypography.body.copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w600),
        titleLarge: AppTypography.headingPrimary.copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w900),
      ),
    );
  }
}