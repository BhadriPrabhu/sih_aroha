// lib/features/cargo/presentation/screens/cargo_optimization_screen.dart
import 'package:flutter/material.dart';
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
                "Resupply Optimization",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Next Flight: Maitri Base (14 Days)",
                style: TextStyle(fontSize: 14, color: AppColors.accentCyan),
              ),
              const SizedBox(height: 32),
              
              // Capacity Visualization Chart (Mocking the Dribbble graph area)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Capacity Utilization", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("95", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.accentMint, height: 1)),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.0, left: 4),
                          child: Text("%", style: TextStyle(fontSize: 20, color: AppColors.accentMint)),
                        ),
                        Spacer(),
                        Text("1,900 / 2,000 kg", style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Progress Bar mimicking the knapsack limit
                    LinearProgressIndicator(
                      value: 0.95,
                      backgroundColor: AppColors.surface,
                      color: AppColors.accentMint,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Selected Cargo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              
              // Selected Cargo List
              Expanded(
                child: ListView.separated(
                  itemCount: 5,
                  padding: EdgeInsets.only(bottom: 100),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildCargoListTile("Aviation Fuel (Barrel)", "High Criticality", "800 kg", 1.0);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCargoListTile(String title, String subtitle, String weight, double fulfillment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_shipping_outlined, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.accentRed)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(weight, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text("${(fulfillment * 100).toInt()}% Fulfilled", style: const TextStyle(fontSize: 12, color: AppColors.accentMint)),
            ],
          )
        ],
      ),
    );
  }
}