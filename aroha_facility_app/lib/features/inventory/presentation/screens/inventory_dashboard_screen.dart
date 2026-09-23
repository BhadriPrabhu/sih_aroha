// lib/features/inventory/presentation/screens/inventory_dashboard_screen.dart
// import 'package:aroha_facility_app/core/constants/api_constants.dart';
import 'package:aroha_facility_app/core/data/local_database_helper.dart';
import 'package:aroha_facility_app/core/presentation/widgets/tactical_card.dart';
import 'package:aroha_facility_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:dio/dio.dart';
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

  // Telemetry Counts from the criticality API
  int _totalCriticalItems = 0;
  int _totalItemsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  // Future<void> _fetchInventory() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final dio = Dio(
  //       BaseOptions(
  //         connectTimeout: const Duration(seconds: 10),
  //         receiveTimeout: const Duration(seconds: 10),
  //       ),
  //     );

  //     // Fetch stock list and criticality analytics concurrently
  //     final responses = await Future.wait([
  //       dio.get(ApiConstants.getStocks),
  //       dio.get(ApiConstants.getCriticalityCount),
  //     ]);

  //     if (mounted) {
  //       setState(() {
  //         // 1. Process stocks list - wrapped in List.from() to prevent unmodifiable list errors!
  //         if (responses[0].statusCode == 200) {
  //           _inventoryItems = List.from(responses[0].data['stocks'] ?? []);
  //         }

  //         // 2. Process criticality telemetry count
  //         if (responses[1].statusCode == 200 && responses[1].data['success'] == true) {
  //           final data = responses[1].data;
  //           _totalCriticalItems = data['total_critical_items'] ?? data['critical_count'] ?? 0;
  //           _totalItemsCount = data['total_items'] ?? _inventoryItems.length;
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching inventory or criticality data: $e");
  //     // Ensure the list is initialized if the API fails entirely
  //     if (mounted) setState(() => _inventoryItems = []);
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         // TEMPORARY: Inject mock items here so they render even if the API throws an error
  //         _inventoryItems.addAll([
  //           {
  //             'name': 'Mock Oxygen Tanks',
  //             'category': 'Survivals',
  //             'stock_available': 5,
  //           },
  //           {
  //             'name': 'Mock Drone Batteries',
  //             'category': 'Spares',
  //             'stock_available': 35,
  //           }
  //         ]);

  //         // Force the total count to update for the UI test
  //         _totalItemsCount = _inventoryItems.length;
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _fetchInventory() async {
    setState(() => _isLoading = true);
    try {
      // 1. Seed dummy data (only runs once if DB is empty)
      await LocalDatabaseHelper.instance.seedDummyData();

      // 2. Fetch directly from our local SQLite cache
      final localData = await LocalDatabaseHelper.instance.getCachedInventory();

      if (mounted) {
        setState(() {
          _inventoryItems = localData;
          _totalItemsCount = _inventoryItems.length;

          // Calculate critical items (stock <= 10)
          _totalCriticalItems =
              _inventoryItems
                  .where((item) => (item['stock_available'] as num) <= 10)
                  .length;
        });
      }
    } catch (e) {
      print("Offline fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // --- DYNAMIC THEME AWARENESS ---
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText =
        Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText =
        Theme.of(context).textTheme.bodyMedium?.color ??
        AppColors.textSecondary;
    final surfaceColor =
        Theme.of(context).cardTheme.color ?? AppColors.surfaceElevated;
    final borderColor =
        Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    final filteredItems =
        _inventoryItems.where((item) {
          final matchesCategory =
              selectedCategory == 'All' || item['category'] == selectedCategory;
          final itemName = (item['name'] ?? '').toString().toLowerCase();
          final matchesSearch = itemName.contains(_searchQuery);
          return matchesCategory && matchesSearch;
        }).toList();

    return Scaffold(
      // backgroundColor removed! Let the Theme engine handle it.
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
                  Text(
                    "Inventory",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.add,
                        color: AppColors.polarCyan,
                        onPressed: () async {
                          final shouldRefresh = await context.push(
                            '/inventory/log',
                          );
                          if (shouldRefresh == true) _fetchInventory();
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.qr_code_scanner,
                        color: AppColors.statusNominal,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // STATS ROW
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      title: "Inventory",
                      value:
                          _totalItemsCount > 0
                              ? "$_totalItemsCount"
                              : "${_inventoryItems.length}",
                      subtitle: "Total Logged",
                      topIcon: Icons.category,
                      bottomIcon: Icons.trending_up,
                      color: AppColors.statusNominal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      title: "Alerts",
                      value: "$_totalCriticalItems",
                      subtitle: "Critical Stock",
                      topIcon: Icons.warning,
                      bottomIcon: Icons.event_note,
                      color: AppColors.statusCritical,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // THEME-AWARE SEARCH BAR
              TextField(
                onChanged:
                    (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                style: TextStyle(color: primaryText),
                decoration: InputDecoration(
                  hintText: "Search supplies...",
                  hintStyle: TextStyle(color: secondaryText),
                  prefixIcon: Icon(Icons.search, color: secondaryText),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Matched to tactical 12px
                    borderSide: BorderSide(
                      color: borderColor,
                      width: isLight ? 2 : 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: isLight ? 2 : 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.polarCyan,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // THEME-AWARE CATEGORY CHIPS
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

                    // Brutalist High-Contrast Chip Logic
                    final chipBg = isSelected ? primaryText : surfaceColor;
                    final chipText = isSelected ? scaffoldBg : secondaryText;
                    final chipBorder = isSelected ? primaryText : borderColor;

                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Matched to tactical 12px
                          border: Border.all(
                            color: chipBorder,
                            width: isLight && !isSelected ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category.toUpperCase(), // Uppercase for tactical feel
                          style: TextStyle(
                            color: chipText,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.5,
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
                            color: AppColors.polarCyan,
                          ),
                        )
                        : filteredItems.isEmpty
                        ? Center(
                          child: Text(
                            "No items found",
                            style: TextStyle(color: secondaryText),
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 120),
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
  required BuildContext context, // Added context requirement
  required String title,
  required String value,
  required String subtitle,
  required IconData topIcon,
  required IconData bottomIcon,
  required Color color,
}) {
  final isLight = Theme.of(context).brightness == Brightness.light;
  final surfaceColor =
      Theme.of(context).cardTheme.color ?? AppColors.surfaceElevated;
  final primaryText =
      Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
  final secondaryText =
      Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
  final borderColor =
      Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;

  return Container(
    height: 150,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(12), // Rigid tactical corners
      border: Border.all(
        color: isLight ? const Color(0xFF000000) : color.withOpacity(0.3),
        width: isLight ? 2 : 1, // Thick border in High-Albedo mode
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isLight ? const Color(0xFF000000) : color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                topIcon,
                color: isLight ? const Color(0xFFFFFFFF) : color,
                size: 20,
              ),
            ),
          ],
        ),
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
                    style: TextStyle(
                      fontFamily:
                          AppTypography.monoFont, // Telemetry font for numbers
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: primaryText,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, right: 4.0),
              child: Icon(
                bottomIcon,
                color:
                    isLight ? const Color(0xFF000000) : color.withOpacity(0.5),
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
  final Map<String, dynamic> itemData;

  const _InventoryItemCard({required this.onTap, required this.itemData});

  @override
  Widget build(BuildContext context) {
    // Dynamic Tactical Status Logic
    final double available = (itemData['stock_available'] ?? 0).toDouble();
    String? statusLabel;
    Color? statusColor;

    if (available <= 10) {
      statusLabel = "CRITICAL";
      statusColor = AppColors.statusCritical;
    } else if (available <= 50) {
      statusLabel = "WARNING";
      statusColor = AppColors.statusWarning;
    }

    return TacticalCard(
      onTap: onTap,
      statusLabel: statusLabel,
      statusColor: statusColor,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.canvasBlack,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.polarCyan,
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
                  style: AppTypography.headingPrimary.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (itemData['category'] ?? "General")
                          .toString()
                          .toUpperCase(),
                      style: AppTypography.label,
                    ),
                    Row(
                      children: [
                        const Text("QTY: ", style: AppTypography.label),
                        Text(
                          "${itemData['stock_available'] ?? 0}",
                          style: AppTypography.telemetry,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
