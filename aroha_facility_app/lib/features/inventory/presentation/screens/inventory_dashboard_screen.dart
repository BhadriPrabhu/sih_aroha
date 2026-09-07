// lib/features/inventory/presentation/screens/inventory_dashboard_screen.dart
import 'package:aroha_facility_app/core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';

class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() =>
      _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
  final List<String> categories = [
    'All',
    'Fuel',
    'Food',
    'Medical',
    'Spares',
    'Survivals',
    'Machineries',
    'Scientific',
    'Others',
  ];
  String selectedCategory = 'All';

  List<dynamic> _inventoryItems = [];
  bool _isLoading = true;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() => _isLoading = true);
    try {
      // Add timeouts to prevent infinite hanging
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await dio.get(ApiConstants.getStocks);

      if (response.statusCode == 200) {
        setState(() {
          // TARGET THE ARRAY: Safely extract the 'stocks' list from the JSON object
          _inventoryItems = response.data['stocks'] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching inventory: $e");
    } finally {
      // ALWAYS stop the spinner, regardless of success or failure
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final filteredItems =
        _inventoryItems.where((item) {
          // 1. Check Category
          final matchesCategory =
              selectedCategory == 'All' || item['category'] == selectedCategory;

          // 2. Check Search Query (case-insensitive)
          final itemName = (item['name'] ?? '').toString().toLowerCase();
          final matchesSearch = itemName.contains(_searchQuery);

          return matchesCategory && matchesSearch;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Station Inventory",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        icon:
                            Icons.add_rounded, // Rounded icons look friendlier
                        color: AppColors.accentCyan,
                        onPressed: () async {
                          final shouldRefresh = await context.push(
                            '/inventory/log',
                          );
                          if (shouldRefresh == true) {
                            _fetchInventory();
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.qr_code_scanner_rounded,
                        color: AppColors.accentMint,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Inventory",
                      value: "${_inventoryItems.length}",
                      subtitle: "Total Logged",
                      topIcon: Icons.category_rounded,
                      bottomIcon:
                          Icons
                              .trending_up_rounded, // Adds that little sparkline look
                      color: AppColors.accentMint,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: "Alerts",
                      value: "12",
                      subtitle: "Critical Stock",
                      topIcon: Icons.warning_rounded,
                      bottomIcon:
                          Icons
                              .event_note_rounded, // Like the calendar in the image
                      color: AppColors.accentRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search supplies...",
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.cardBorder,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? AppColors.background
                                    : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentMint,
                          ),
                        )
                        : filteredItems.isEmpty
                        ? const Center(
                          child: Text(
                            "No items found",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                        : isDesktop
                        ? GridView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2.5,
                              ),
                          itemCount: filteredItems.length,
                          itemBuilder:
                              (context, index) => _InventoryItemCard(
                                itemData: filteredItems[index],
                                onTap:
                                    () => context.push(
                                      '/inventory/details',
                                      extra: filteredItems[index],
                                    ),
                              ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: filteredItems.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 12),
                          itemBuilder:
                              (context, index) => _InventoryItemCard(
                                itemData: filteredItems[index],
                                onTap:
                                    () => context.push(
                                      '/inventory/details',
                                      extra: filteredItems[index],
                                    ),
                              ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildStatCard({
  required String title,
  required String value,
  required String subtitle,
  required IconData topIcon,
  required IconData bottomIcon,
  required Color color,
}) {
  return Container(
    height: 150, // Fixed height creates that perfect boxy/squircle proportion
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(
        32,
      ), // Deep, soft radius like the reference image
      border: Border.all(
        color: color.withOpacity(0.15),
        width: 1.5, // Subtle OLED edge glow
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // TOP ROW: Title (Left) & Circular Icon (Right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape:
                    BoxShape
                        .circle, // Circular icon container from the reference
              ),
              child: Icon(topIcon, color: color, size: 22),
            ),
          ],
        ),

        // BOTTOM ROW: Value & Subtitle (Left) & Secondary Icon (Right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 34, // Huge, bold numbers
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, right: 4.0),
              child: Icon(
                bottomIcon, // Small aesthetic icon for the bottom right
                color: color.withOpacity(0.5),
                size: 24,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildActionButton({
  required IconData icon,
  required Color color,
  required VoidCallback onPressed,
}) {
  return Material(
    color: color.withOpacity(0.12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: color.withOpacity(0.2), width: 1),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      splashColor: color.withOpacity(0.2),
      highlightColor: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(icon, color: color, size: 24),
      ),
    ),
  );
}

class _InventoryItemCard extends StatelessWidget {
  final VoidCallback onTap;
  final Map<String, dynamic> itemData; // Modified to accept live API data

  const _InventoryItemCard({required this.onTap, required this.itemData});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.accentMint,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    itemData['name'] ?? "Unknown Item",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        itemData['category'] ?? "General",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          "Stock: ${itemData['stock_available'] ?? 0}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
