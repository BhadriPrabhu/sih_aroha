// lib/app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_notifier.dart';

class ArohaApp extends StatefulWidget {
  const ArohaApp({super.key});

  @override
  State<ArohaApp> createState() => _ArohaAppState();
}

class _ArohaAppState extends State<ArohaApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter('fieldTechnician');
  }

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the app in a listener for real-time theme toggling
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeNotifier.themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp.router(
          title: 'AROHA Core',
          debugShowCheckedModeBanner: false,
          
          // 2. Map the state to the Material App theme engine
          themeMode: currentMode,
          theme: AppTheme.highAlbedoTheme,
          darkTheme: AppTheme.tacticalTheme,
          
          routerConfig: _router,
        );
      },
    );
  }
}