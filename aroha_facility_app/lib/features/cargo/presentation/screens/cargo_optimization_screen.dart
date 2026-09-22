// lib/features/cargo/presentation/screens/cargo_optimization_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CargoOptimizationScreen extends StatelessWidget {
  const CargoOptimizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME AWARENESS ---
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceObsidian;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;

    return Scaffold(
      // backgroundColor removed for theme awareness
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text("Active Shipments", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryText, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text("NCPOR LOGISTICS & TRACKING", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.polarCyan, letterSpacing: 1.0)),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("LAST ACTIVITY", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: secondaryText, letterSpacing: 0.5)),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(minimumSize: const Size(48, 48)), // Fitts's Law Failsafe
                    child: Text("VIEW ALL", style: TextStyle(color: isLight ? Colors.black : AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 120),
                  children: [
                    _buildShipmentCard(
                      context: context,
                      title: "Ice-Class Vessel Resupply",
                      route: "Goa, IND → Bharati, ANT",
                      id: "SHP-8942",
                      status: "AT PORT",
                      statusColor: AppColors.statusWarning,
                      icon: Icons.directions_boat_filled_outlined,
                      isLight: isLight, surface: surfaceColor, border: borderColor, pText: primaryText, sText: secondaryText,
                    ),
                    const SizedBox(height: 16),
                    _buildShipmentCard(
                      context: context,
                      title: "Emergency Airlift Alpha",
                      route: "Cape Town, SA → Maitri, ANT",
                      id: "AIR-1109",
                      status: "DELIVERED",
                      statusColor: AppColors.statusNominal,
                      icon: Icons.airplanemode_active,
                      isLight: isLight, surface: surfaceColor, border: borderColor, pText: primaryText, sText: secondaryText,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentCard({
    required BuildContext context, required String title, required String route,
    required String id, required String status, required Color statusColor,
    required IconData icon, required bool isLight, required Color surface, 
    required Color border, required Color pText, required Color sText,
  }) {
    return InkWell(
      onTap: () => context.push('/cargo/details'),
      borderRadius: BorderRadius.circular(12), // Tactical corners
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: isLight ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 64, height: 64, // 64dp for heavy gloves
              decoration: BoxDecoration(
                color: isLight ? Colors.white : AppColors.canvasBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border, width: isLight ? 2 : 1),
              ),
              child: Icon(icon, color: AppColors.polarCyan, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: pText)),
                  const SizedBox(height: 4),
                  Text(route, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sText)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: isLight ? Colors.white : AppColors.canvasBlack, borderRadius: BorderRadius.circular(4), border: Border.all(color: border)),
                  child: Text(id, style: AppTypography.telemetry.copyWith(fontSize: 11, color: pText)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
                  ),
                  child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}