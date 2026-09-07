// lib/features/shell/presentation/screens/adaptive_shell_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';

class AdaptiveShellScreen extends StatelessWidget {
  final Widget child;

  const AdaptiveShellScreen({super.key, required this.child});

  static const List<Map<String, dynamic>> _navigationItems = [
    {'icon': Icons.inventory_2_outlined, 'activeIcon': Icons.inventory_2, 'route': '/inventory', 'label': 'Supplies'},
    {'icon': Icons.alt_route_outlined, 'activeIcon': Icons.alt_route, 'route': '/cargo', 'label': 'Optimization'},
    {'icon': Icons.snowshoeing_outlined, 'activeIcon': Icons.snowshoeing, 'route': '/movement', 'label': 'Movement'},
    {'icon': Icons.warning_amber_rounded, 'activeIcon': Icons.warning_rounded, 'route': '/emergency', 'label': 'Alerts'},
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/cargo')) return 1;
    if (location.startsWith('/movement')) return 2;
    if (location.startsWith('/emergency')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    context.go(_navigationItems[index]['route'] as String);
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = ResponsiveLayout.isDesktop(context);
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // 1. DESKTOP / WEB NAVIGATION BAR (>800px)
          if (isWeb)
            Container(
              width: 260,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(right: BorderSide(color: AppColors.cardBorder, width: 1)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Station Status Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.accentMint.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.accentMint.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.hub_outlined, color: AppColors.accentMint),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("AROHA CORE", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            Text("BHARATI STATION", style: TextStyle(color: AppColors.accentMint, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Navigation Entries
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: _navigationItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final item = _navigationItems[index];
                        final isSelected = selectedIndex == index;
                        return InkWell(
                          onTap: () => _onItemTapped(index, context),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.accentMint.withOpacity(0.4) : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? item['activeIcon'] : item['icon'],
                                  color: isSelected ? AppColors.accentMint : AppColors.textSecondary,
                                  size: 22,
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  item['label'],
                                  style: TextStyle(
                                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // 2. MAIN APPLICATION WORKSPACE
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(key: ValueKey('shell_navigator_wrapper'), child: child),

                // 3. FLOATING TACTICAL BOTTOM BAR (≤ 800px)
                if (!isWeb)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          height: 72,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.cardBorder.withOpacity(0.8), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(_navigationItems.length, (index) {
                              final item = _navigationItems[index];
                              final isSelected = selectedIndex == index;
                              return GestureDetector(
                                onTap: () => _onItemTapped(index, context),
                                behavior: HitTestBehavior.opaque,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.accentMint : Colors.transparent,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Icon(
                                    isSelected ? item['activeIcon'] : item['icon'],
                                    color: isSelected ? AppColors.background : AppColors.textSecondary,
                                    size: 26,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}