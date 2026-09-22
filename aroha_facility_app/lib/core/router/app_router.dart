// lib/core/router/app_router.dart
import 'package:aroha_facility_app/features/auth/presentation/screens/login_screen.dart';
import 'package:aroha_facility_app/features/cargo/presentation/screens/cargo_detail_screen.dart';
import 'package:aroha_facility_app/features/cargo/presentation/screens/cargo_optimization_screen.dart';
import 'package:aroha_facility_app/features/cargo/presentation/screens/live_tracking_screen.dart';
import 'package:aroha_facility_app/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:aroha_facility_app/features/inventory/presentation/screens/inventory_dashboard_screen.dart';
import 'package:aroha_facility_app/features/inventory/presentation/screens/item_detail_screen.dart';
import 'package:aroha_facility_app/features/inventory/presentation/screens/log_item_screen.dart';
import 'package:aroha_facility_app/features/movement/presentation/screens/member_profile_screen.dart';
import 'package:aroha_facility_app/features/movement/presentation/screens/movement_screen.dart';
import 'package:aroha_facility_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:aroha_facility_app/features/profile/presentation/screens/sync_screen.dart';
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
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
                builder: (context, state) {
                  // Extract the map passed from the dashboard
                  final data = state.extra as Map<String, dynamic>? ?? {};
                  return ItemDetailScreen(itemData: data);
                },
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
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) => const CargoDetailScreen(),
                routes: [
                  GoRoute(
                    path: 'tracking',
                    builder: (context, state) => const LiveTrackingScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/movement',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: MovementScreen()),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) {
                  // Extract the live member data map
                  final data = state.extra as Map<String, dynamic>? ?? {};
                  return MemberProfileScreen(memberData: data);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/emergency',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: EmergencyScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: '/sync',
            builder: (context, state) => const SyncScreen(),
          ),
        ],
      ),
    ],
  );
}
