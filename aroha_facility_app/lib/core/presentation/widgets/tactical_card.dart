// lib/core/presentation/widgets/tactical_card.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../theme/app_typography.dart';

class TacticalCard extends StatelessWidget {
  final Widget child;
  final String? statusLabel;
  final Color? statusColor;
  final VoidCallback? onTap;

  const TacticalCard({
    super.key,
    required this.child,
    this.statusLabel,
    this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceObsidian,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderHairline, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        highlightColor: AppColors.borderActive.withOpacity(0.1),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
            
            // Grounding Status Badge (Top Right)
            if (statusLabel != null && statusColor != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor!.withOpacity(0.12),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    border: Border(
                      left: BorderSide(color: statusColor!.withOpacity(0.3)),
                      bottom: BorderSide(color: statusColor!.withOpacity(0.3)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel!.toUpperCase(),
                        style: AppTypography.label.copyWith(color: statusColor),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}