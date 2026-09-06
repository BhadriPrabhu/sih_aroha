// lib/app.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class ArohaApp extends StatelessWidget {
  const ArohaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter('fieldTechnician');

    return MaterialApp.router(
      title: 'AROHA Core',
      debugShowCheckedModeBanner: false, // Hides the debug banner for a cleaner look
      theme: AppTheme.darkOledTheme,
      routerConfig: router,
    );
  }
}