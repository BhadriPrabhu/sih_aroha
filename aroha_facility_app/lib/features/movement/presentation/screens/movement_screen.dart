// lib/features/movement/presentation/screens/movement_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class MovementScreen extends StatefulWidget {
  const MovementScreen({super.key});

  @override
  State<MovementScreen> createState() => _MovementScreenState();
}

class _MovementScreenState extends State<MovementScreen> {
  final List<Map<String, String>> groups = [
    {'name': 'My Group', 'id': 'M'},
    {'name': 'All Members', 'id': 'A'},
    {'name': 'Expedition Alpha', 'id': 'E'},
    {'name': 'Logistics Team', 'id': 'L'},
    {'name': 'Medical Staff', 'id': 'M'},
  ];

  String selectedGroup = 'My Group';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                "Personnel Movement",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            // 1. Group Selector (Instagram Stories Style)
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: groups.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final isSelected = selectedGroup == group['name'];

                  return GestureDetector(
                    onTap: () => setState(() => selectedGroup = group['name']!),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.accentMint : AppColors.cardBorder,
                              width: isSelected ? 3 : 1,
                            ),
                            color: AppColors.surfaceElevated,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            group['id']!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.accentMint : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          group['name']!.length > 10 
                              ? '${group['name']!.substring(0, 8)}...' 
                              : group['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(
                "Roster",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),

            // 2. Member Grid Layer (2 per row)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100), // 100px buffer for bottom nav
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85, // Optimized for vertical card layout
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  // Mocking alternating status for visual testing
                  final isOutside = index == 1;
                  final isSleeping = index == 3;
                  
                  return _buildMemberTile(
                    name: "Dr. Aravind S.",
                    role: "Medical Officer",
                    isOutside: isOutside,
                    isSleeping: isSleeping,
                    onTap: () => context.push('/movement/profile'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile({
    required String name,
    required String role,
    required bool isOutside,
    required bool isSleeping,
    required VoidCallback onTap,
  }) {
    Color statusColor = AppColors.accentMint;
    String statusText = "Inside";

    if (isSleeping) {
      statusColor = AppColors.textMuted;
      statusText = "Sleeping";
    } else if (isOutside) {
      statusColor = AppColors.accentAmber;
      statusText = "Outside";
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              alignment: Alignment.center,
              child: Text(
                name[0], // First letter
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
              ),
            ),
            const SizedBox(height: 12),
            // Details
            Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              role,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}