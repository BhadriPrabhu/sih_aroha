// lib/features/inventory/presentation/screens/item_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ItemDetailScreen({super.key, required this.itemData});

  @override
  Widget build(BuildContext context) {
    // Extract live data safely
    final String name = itemData['name'] ?? "Unknown Item";
    final String category = itemData['category'] ?? "General";
    final double currentStock = (itemData['stock_available'] as num?)?.toDouble() ?? 0.0;
    final String criticality = itemData['criticality_rate']?.toString() ?? "N/A";

    // Mocking initial/used stock for the visualizer since API only provides current stock
    final double initialStock = currentStock > 0 ? currentStock * 1.5 : 100.0;
    final double usedStock = initialStock - currentStock;
    final double stockPercentage = currentStock / initialStock;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text("Item Details", style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. Header Information
            Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.accentMint.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text("Category: $category", style: const TextStyle(color: AppColors.accentMint, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            const SizedBox(height: 40),

            // 2. Circular Stock Visualizer
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: stockPercentage,
                      strokeWidth: 16,
                      backgroundColor: AppColors.surfaceElevated,
                      color: stockPercentage < 0.2 ? AppColors.accentRed : AppColors.accentCyan,
                      strokeCap: StrokeCap.round,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${(stockPercentage * 100).toInt()}%", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const Text("Available", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 3. Stock Count Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricColumn("Initial", "${initialStock.toInt()}", AppColors.textSecondary),
                Container(width: 1, height: 40, color: AppColors.cardBorder),
                _buildMetricColumn("Used", "${usedStock.toInt()}", AppColors.accentRed),
                Container(width: 1, height: 40, color: AppColors.cardBorder),
                _buildMetricColumn("Current", "${currentStock.toInt()}", AppColors.accentCyan),
              ],
            ),
            const SizedBox(height: 32),

            // 4. Advanced Analytics Cards
            Row(
              children: [
                Expanded(child: _buildInfoCard("Days of Supply (DOS)", "14 Days", Icons.calendar_today)), // Mock DOS for now
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard("Criticality Score", criticality, Icons.warning_amber_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}