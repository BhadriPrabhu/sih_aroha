// lib/core/router/app_router.dart
import 'package:aroha_facility_app/features/cargo/presentation/screens/cargo_optimization_screen.dart';
import 'package:aroha_facility_app/features/inventory/presentation/screens/inventory_dashboard_screen.dart';
import 'package:aroha_facility_app/features/inventory/presentation/screens/item_detail_screen.dart';
import 'package:aroha_facility_app/features/inventory/presentation/screens/log_item_screen.dart';
import 'package:aroha_facility_app/features/movement/presentation/screens/member_profile_screen.dart';
import 'package:aroha_facility_app/features/movement/presentation/screens/movement_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/presentation/screens/adaptive_shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

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
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: InventoryDashboardScreen()),
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) => const ItemDetailScreen(),
              ),
              GoRoute(
                path: 'log',
                builder: (context, state) => const LogItemScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/cargo',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: CargoOptimizationScreen()),
          ),
          GoRoute(
            path: '/movement',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: MovementScreen()),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => const MemberProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/emergency',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: Center(child: Text("SATCOM Emergency Channel")),
                ),
          ),
        ],
      ),
    ],
  );
}
