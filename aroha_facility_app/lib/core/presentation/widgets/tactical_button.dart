// lib/core/presentation/widgets/tactical_button.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../theme/app_typography.dart';

class TacticalButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;

  const TacticalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDestructive 
        ? AppColors.statusCritical 
        : (isPrimary ? AppColors.polarCyan : AppColors.textPrimary);
        
    final bgColor = isPrimary ? baseColor.withOpacity(0.1) : Colors.transparent;

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: baseColor.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        highlightColor: baseColor.withOpacity(0.2),
        splashColor: baseColor.withOpacity(0.3),
        child: Container(
          height: 60, // Minimum hit area for heavy gloves
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: baseColor, size: 24),
                const SizedBox(width: 12),
              ],
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: AppTypography.primaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isPrimary ? AppColors.textPrimary : baseColor,
                ),
              ),
              const Spacer(),
              // Industrial Grip Notches
              Row(
                children: List.generate(3, (index) => Container(
                  width: 2,
                  height: 16,
                  margin: const EdgeInsets.only(left: 4),
                  color: baseColor.withOpacity(0.3),
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}