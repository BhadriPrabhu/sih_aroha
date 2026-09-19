// lib/features/profile/presentation/screens/sync_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/data/local_database_helper.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  List<Map<String, dynamic>> _unsyncedItems = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _fetchUnsyncedData();
  }

  Future<void> _fetchUnsyncedData() async {
    setState(() => _isLoading = true);
    final items = await LocalDatabaseHelper.instance.getUnsyncedInventory();
    if (mounted) {
      setState(() {
        _unsyncedItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _simulateUplink() async {
    if (_unsyncedItems.isEmpty) return;
    
    setState(() => _isSyncing = true);
    
    // Simulate network delay for the SATCOM uplink
    await Future.delayed(const Duration(seconds: 3));
    
    // In a real scenario, you would POST to Dio here. 
    // For now, we update SQLite to mark them as synced.
    await LocalDatabaseHelper.instance.cacheInventory(_unsyncedItems, isSynced: true);
    
    if (mounted) {
      setState(() => _isSyncing = false);
      _fetchUnsyncedData(); // Refresh the list (should be empty now)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('UPLINK SUCCESSFUL. ALL DATA SYNCED.', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          backgroundColor: AppColors.statusNominal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME AWARENESS ---
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceObsidian;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text("Terminal Uplink", style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Network Status Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFE2E8F0) : AppColors.canvasBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: isLight ? 3 : 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      _unsyncedItems.isEmpty ? Icons.cloud_done : Icons.cloud_off, 
                      color: _unsyncedItems.isEmpty ? AppColors.statusNominal : AppColors.statusWarning, 
                      size: 32
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("SATCOM QUEUE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: secondaryText, letterSpacing: 1.0)),
                        const SizedBox(height: 4),
                        Text(
                          _unsyncedItems.isEmpty ? "ALL DATA SYNCED" : "${_unsyncedItems.length} PAYLOADS PENDING", 
                          style: AppTypography.telemetry.copyWith(fontSize: 16, color: primaryText, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // 2. Pending Items List
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.polarCyan))
                : _unsyncedItems.isEmpty
                  ? Center(
                      child: Text("NO PENDING LOGS", style: TextStyle(color: secondaryText, fontWeight: FontWeight.w800, letterSpacing: 1.5))
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _unsyncedItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _unsyncedItems[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: isLight ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.inventory_2, color: secondaryText, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'].toString().toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: primaryText)),
                                    const SizedBox(height: 4),
                                    Text("QTY: ${item['stock_available']}", style: AppTypography.telemetry.copyWith(color: secondaryText)),
                                  ],
                                ),
                              ),
                              Icon(Icons.upload_file, color: AppColors.statusWarning.withOpacity(0.5)),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // 3. Human Factors: Giant Transmit Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _unsyncedItems.isEmpty || _isSyncing ? null : _simulateUplink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLight ? Colors.black : AppColors.polarCyan,
                    foregroundColor: isLight ? Colors.white : Colors.black,
                    disabledBackgroundColor: surfaceColor,
                    disabledForegroundColor: secondaryText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _unsyncedItems.isEmpty || _isSyncing 
                          ? borderColor 
                          : (isLight ? Colors.black : AppColors.polarCyan), 
                        width: isLight ? 4 : 2
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: _isSyncing 
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.canvasBlack, strokeWidth: 3)),
                          SizedBox(width: 16),
                          Text("TRANSMITTING...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.satellite_alt, size: 28),
                          const SizedBox(width: 12),
                          Text("INITIATE UPLINK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        ],
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}