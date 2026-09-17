// lib/core/theme/theme_notifier.dart
import 'package:flutter/material.dart';

class ThemeNotifier {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

  static void toggleTheme(bool isHighAlbedo) {
    themeMode.value = isHighAlbedo ? ThemeMode.light : ThemeMode.dark;
  }
}