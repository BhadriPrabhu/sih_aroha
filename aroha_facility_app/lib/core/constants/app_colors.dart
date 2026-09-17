// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // --------------------------------------------------------
  // 1. NEW TACTICAL OLED TOKENS
  // --------------------------------------------------------
  static const Color canvasBlack = Color(0xFF000000);
  static const Color surfaceObsidian = Color(0xFF0B0F14);
  static const Color surfaceElevated = Color(0xFF10141A);
  
  static const Color borderHairline = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)
  static const Color borderActive = Color(0x2600D2FF);   // rgba(0, 210, 255, 0.15)
  
  static const Color polarCyan = Color(0xFF00D2FF);
  
  static const Color statusNominal = Color(0xFF10B981);  // Muted Emerald
  static const Color statusWarning = Color(0xFFF59E0B);  // Aviation Amber
  static const Color statusCritical = Color(0xFFEF4444); // Beacon Red
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textBody = Color(0xFF94A3B8);       // Slate 400
  static const Color textMeta = Color(0xFF64748B);       // Slate 500


  // --------------------------------------------------------
  // 2. LEGACY MAPPING (Fixes compilation errors)
  // Maps old screen variables to the new rugged tokens
  // --------------------------------------------------------
  static const Color background = canvasBlack;
  static const Color surface = surfaceObsidian;
  
  static const Color cardBorder = borderHairline;
  
  static const Color accentMint = statusNominal;
  static const Color accentAmber = statusWarning;
  static const Color accentRed = statusCritical;
  static const Color accentCyan = polarCyan;
  
  static const Color textSecondary = textBody;
  static const Color textMuted = textMeta;
}