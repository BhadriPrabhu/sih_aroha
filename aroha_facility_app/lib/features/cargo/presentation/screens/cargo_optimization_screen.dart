// lib/features/cargo/presentation/screens/cargo_optimization_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class CargoOptimizationScreen extends StatelessWidget {
  const CargoOptimizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text(
                "Active Shipments",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "NCPOR Logistics & Tracking",
                style: TextStyle(fontSize: 14, color: AppColors.accentCyan),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Last Activity",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("View All", style: TextStyle(color: AppColors.textSecondary)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              
              // Active Shipments List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 120), // Clears the bottom floating nav
                  children: [
                    _buildShipmentCard(
                      context: context,
                      title: "Ice-Class Vessel Resupply",
                      route: "Goa, IND → Bharati, ANT",
                      id: "ID: SHP-8942",
                      status: "At Port",
                      statusColor: AppColors.accentAmber,
                      icon: Icons.directions_boat_filled_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildShipmentCard(
                      context: context,
                      title: "Emergency Airlift Alpha",
                      route: "Cape Town, SA → Maitri, ANT",
                      id: "ID: AIR-1109",
                      status: "Delivered",
                      statusColor: AppColors.accentMint,
                      icon: Icons.airplanemode_active,
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
    required BuildContext context,
    required String title,
    required String route,
    required String id,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => context.push('/cargo/details'),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Icon / Image container
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Icon(icon, color: AppColors.accentCyan, size: 36),
            ),
            const SizedBox(width: 16),
            
            // Middle Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(route, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            
            // Right ID & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}