// lib/features/inventory/presentation/screens/item_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ItemDetailScreen({super.key, required this.itemData});

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME AWARENESS ---
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceElevated;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;

    // Extract live data safely
    final String name = itemData['name'] ?? "Unknown Item";
    final String category = itemData['category'] ?? "General";
    final double currentStock = (itemData['stock_available'] as num?)?.toDouble() ?? 0.0;
    final String criticality = itemData['criticality_rate']?.toString() ?? "N/A";

    final double initialStock = currentStock > 0 ? currentStock * 1.5 : 100.0;
    final double usedStock = initialStock - currentStock;
    final double stockPercentage = currentStock / initialStock;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text("Item Details", style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. Header Information
            Text(name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: primaryText), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLight ? AppColors.canvasBlack : AppColors.statusNominal.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text(
                "CATEGORY: ${category.toUpperCase()}", 
                style: TextStyle(
                  color: isLight ? Colors.white : AppColors.statusNominal, 
                  fontWeight: FontWeight.w800, 
                  fontSize: 11,
                  letterSpacing: 1.0,
                )
              ),
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
                      backgroundColor: surfaceColor,
                      color: stockPercentage < 0.2 ? AppColors.statusCritical : AppColors.polarCyan,
                      strokeCap: StrokeCap.round,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${(stockPercentage * 100).toInt()}%", 
                          style: AppTypography.telemetry.copyWith(fontSize: 40, fontWeight: FontWeight.w900, color: primaryText)
                        ),
                        Text("AVAILABLE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondaryText, letterSpacing: 1.0)),
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
                _buildMetricColumn("INITIAL", "${initialStock.toInt()}", secondaryText, AppTypography.telemetry.copyWith(color: secondaryText, fontSize: 24, fontWeight: FontWeight.bold)),
                Container(width: 1, height: 40, color: borderColor),
                _buildMetricColumn("USED", "${usedStock.toInt()}", secondaryText, AppTypography.telemetry.copyWith(color: AppColors.statusCritical, fontSize: 24, fontWeight: FontWeight.bold)),
                Container(width: 1, height: 40, color: borderColor),
                _buildMetricColumn("CURRENT", "${currentStock.toInt()}", secondaryText, AppTypography.telemetry.copyWith(color: AppColors.polarCyan, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),

            // 4. Advanced Analytics Cards
            Row(
              children: [
                Expanded(child: _buildInfoCard("DOS", "14 Days", Icons.calendar_today, surfaceColor, borderColor, primaryText, secondaryText, isLight)),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard("CRITICALITY", criticality, Icons.warning_amber_rounded, surfaceColor, borderColor, primaryText, secondaryText, isLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color labelColor, TextStyle valueStyle) {
    return Column(
      children: [
        Text(value, style: valueStyle),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color surface, Color border, Color primaryText, Color secondaryText, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: isLight ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isLight ? Colors.black : secondaryText, size: 20),
          const SizedBox(height: 12),
          Text(value, style: AppTypography.telemetry.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: primaryText)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: secondaryText, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}