// lib/app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

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
    return MaterialApp.router(
      title: 'AROHA Core',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkOledTheme,
      routerConfig: _router,
    );
  }
}