// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/presentation/screens/adaptive_shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(String initialRole) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/inventory',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AdaptiveShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/inventory',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text("Inventory Dashboard")),
            ),
          ),
          GoRoute(
            path: '/cargo',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text("Knapsack Resupply Optimizer")),
            ),
          ),
          GoRoute(
            path: '/movement',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text("Field Personnel Tracking")),
            ),
          ),
          GoRoute(
            path: '/emergency',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text("SATCOM Emergency Channel")),
            ),
          ),
        ],
      ),
    ],
  );
}