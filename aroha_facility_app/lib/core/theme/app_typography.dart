// lib/core/theme/app_typography.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTypography {
  static const String primaryFont = 'Inter';
  static const String monoFont = 'JetBrainsMono';

  static const TextStyle headingPrimary = TextStyle(
    fontFamily: primaryFont,
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle body = TextStyle(
    fontFamily: primaryFont,
    color: AppColors.textBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: primaryFont,
    color: AppColors.textMeta,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2, // ~0.1em tracking
  );

  static const TextStyle telemetry = TextStyle(
    fontFamily: monoFont,
    color: AppColors.polarCyan,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}