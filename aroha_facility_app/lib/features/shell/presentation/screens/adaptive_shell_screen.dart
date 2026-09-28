// lib/features/shell/presentation/screens/adaptive_shell_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/network/network_monitor.dart';

class AdaptiveShellScreen extends StatefulWidget {
  final Widget child;

  const AdaptiveShellScreen({super.key, required this.child});

  @override
  State<AdaptiveShellScreen> createState() => _AdaptiveShellScreenState();
}

class _AdaptiveShellScreenState extends State<AdaptiveShellScreen> {
  @override
  void initState() {
    super.initState();
    // Fire up the radar when the shell loads
    NetworkMonitor.startMonitoring();
  }

  static const List<Map<String, dynamic>> _navigationItems = [
    {'icon': Icons.inventory_2_outlined, 'activeIcon': Icons.inventory_2, 'route': '/inventory', 'label': 'Supplies'},
    {'icon': Icons.alt_route_outlined, 'activeIcon': Icons.alt_route, 'route': '/cargo', 'label': 'Logistics'},
    {'icon': Icons.snowshoeing_outlined, 'activeIcon': Icons.snowshoeing, 'route': '/movement', 'label': 'Personnel'},
    {'icon': Icons.warning_amber_rounded, 'activeIcon': Icons.warning_rounded, 'route': '/emergency', 'label': 'Alerts'},
    {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'route': '/profile', 'label': 'Profile'}, 
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/inventory')) return 0;
    if (location.startsWith('/cargo')) return 1;
    if (location.startsWith('/movement')) return 2;
    if (location.startsWith('/emergency')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    context.go(_navigationItems[index]['route']);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    
    // --- DYNAMIC THEME AWARENESS ---
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final navBarBg = Theme.of(context).cardTheme.color ?? AppColors.surfaceObsidian;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.borderHairline;
    final unselectedColor = isLight ? const Color(0xFF64748B) : AppColors.textMeta;
    final selectedTextColor = isLight ? const Color(0xFF000000) : AppColors.textPrimary;
    final activeAccent = isLight ? const Color(0xFF000000) : AppColors.polarCyan;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Column(
        children: [
          // THE PERSISTENT SATCOM HUD
          ValueListenableBuilder<bool>(
            valueListenable: NetworkMonitor.isOnline,
            builder: (context, isOnline, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isOnline ? 0 : 42, // Hides when online, drops down when offline
                width: double.infinity,
                color: AppColors.statusWarning,
                alignment: Alignment.center,
                child: SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, color: Colors.black, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Satcom Offline • Caching Locally",
                          style: AppTypography.label.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontFamily: AppTypography.monoFont,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // The actual screen content
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: navBarBg, 
          border: Border(top: BorderSide(color: borderColor, width: isLight ? 2 : 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navigationItems.length, (index) {
            final isSelected = currentIndex == index;
            final item = _navigationItems[index];

            return Expanded(
              child: InkWell(
                onTap: () => _onItemTapped(index, context),
                highlightColor: activeAccent.withOpacity(0.1),
                splashColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: isSelected ? activeAccent : Colors.transparent, width: isLight ? 4 : 3),
                      right: BorderSide(color: index != _navigationItems.length - 1 ? borderColor : Colors.transparent, width: isLight ? 2 : 1),
                    ),
                    gradient: isSelected && !isLight 
                        ? LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [activeAccent.withOpacity(0.15), Colors.transparent])
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isSelected ? item['activeIcon'] : item['icon'], color: isSelected ? activeAccent : unselectedColor, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        item['label'],
                        style: AppTypography.label.copyWith(
                          color: isSelected ? selectedTextColor : unselectedColor,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}