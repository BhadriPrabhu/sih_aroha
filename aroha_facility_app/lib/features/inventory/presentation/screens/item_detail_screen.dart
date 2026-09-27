// lib/features/inventory/presentation/screens/item_detail_screen.dart
import 'package:aroha_facility_app/core/data/local_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const ItemDetailScreen({super.key, required this.itemData});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Map<String, dynamic> _liveItemData;

  @override
  void initState() {
    super.initState();
    _liveItemData = widget.itemData;

    _refreshLocalData();
  }

  Future<void> _refreshLocalData() async {
    final itemId = _liveItemData['id']?.toString() ?? _liveItemData['name'];
    final db = await LocalDatabaseHelper.instance.database;
    final List<Map<String, dynamic>> items = await db.query('inventory', where: 'id = ?', whereArgs: [itemId]);
    
    if (items.isNotEmpty && mounted) {
      setState(() {
        _liveItemData = items.first; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceElevated;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;

    final String name = _liveItemData['name'] ?? "Unknown Item";
    final String category = _liveItemData['category'] ?? "General";
    
    // Read TRUE initial stock from DB, fallback to current stock if missing (e.g. legacy data)
    final double currentStock = (_liveItemData['stock_available'] as num?)?.toDouble() ?? 0.0;
    final double initialStock = (_liveItemData['initial_stock'] as num?)?.toDouble() ?? currentStock; 
    
    final String criticality = _liveItemData['criticality_rate']?.toString() ?? "N/A";
    final double usedStock = initialStock - currentStock;
    final double stockPercentage = initialStock > 0 ? currentStock / initialStock : 0;

    void _showCheckoutModal(BuildContext context, String itemId, String itemName, double currentStock) {
      final isLight = Theme.of(context).brightness == Brightness.light;
      final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceObsidian;
      final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;

      double usageCount = 1.0;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  border: Border.all(color: isLight ? Colors.black : AppColors.cardBorder, width: isLight ? 3 : 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("LOG USAGE: ${itemName.toUpperCase()}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primaryText)),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (usageCount > 1) setModalState(() => usageCount--);
                          },
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: AppColors.canvasBlack, shape: BoxShape.circle, border: Border.all(color: AppColors.polarCyan, width: 2)),
                            child: const Icon(Icons.remove, color: AppColors.polarCyan, size: 40),
                          ),
                        ),
                        Container(
                          width: 120,
                          alignment: Alignment.center,
                          child: Text(
                            usageCount.toInt().toString(),
                            style: AppTypography.telemetry.copyWith(fontSize: 56, fontWeight: FontWeight.bold, color: primaryText),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (usageCount < currentStock) setModalState(() => usageCount++);
                          },
                          child: Container(
                            width: 80, height: 80,
                            decoration: const BoxDecoration(color: AppColors.polarCyan, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: AppColors.canvasBlack, size: 40),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    SizedBox(
                      width: double.infinity,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () async {
                          await LocalDatabaseHelper.instance.consumeStock(itemId, usageCount);
                          if (!context.mounted) return;
                          await _refreshLocalData();
                          if (!context.mounted) return;
                          
                          context.pop(); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("STOCK UPDATED. QUEUED FOR UPLINK.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              backgroundColor: AppColors.statusWarning,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusWarning,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("CONFIRM DEDUCTION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => context.pop(true), // Force dashboard refresh on exit to show updated stock
        ),
        title: Text("Item Details", style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: primaryText), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: isLight ? AppColors.canvasBlack : AppColors.statusNominal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(
                "CATEGORY: ${category.toUpperCase()}",
                style: TextStyle(color: isLight ? Colors.white : AppColors.statusNominal, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(height: 40),

            Center(
              child: SizedBox(
                width: 200, height: 200,
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
                        Text("${(stockPercentage * 100).toInt()}%", style: AppTypography.telemetry.copyWith(fontSize: 40, fontWeight: FontWeight.w900, color: primaryText)),
                        Text("AVAILABLE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondaryText, letterSpacing: 1.0)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

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

            Row(
              children: [
                Expanded(child: _buildInfoCard("DOS", "14 Days", Icons.calendar_today, surfaceColor, borderColor, primaryText, secondaryText, isLight)),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard("CRITICALITY", criticality, Icons.warning_amber_rounded, surfaceColor, borderColor, primaryText, secondaryText, isLight)),
              ],
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 80,
              child: ElevatedButton(
                onPressed: () {
                  final itemId = _liveItemData['id']?.toString() ?? _liveItemData['name'];
                  _showCheckoutModal(context, itemId, name, currentStock);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLight ? Colors.black : AppColors.polarCyan,
                  foregroundColor: isLight ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.output_rounded, size: 28, color: Colors.black),
                    SizedBox(width: 12),
                    Text("Checkout Item", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: AppTypography.monoFont)),
                  ],
                ),
              ),
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
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: isLight ? 2 : 1)),
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