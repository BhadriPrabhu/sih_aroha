// lib/features/emergency/presentation/screens/emergency_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  bool _isTransmitting = false;
  double _holdProgress = 0.0;
  
  List<dynamic> _criticalAlerts = [];
  bool _isLoadingAlerts = true;

  @override
  void initState() {
    super.initState();
    _fetchCriticalAlerts();
  }

  Future<void> _fetchCriticalAlerts() async {
    setState(() => _isLoadingAlerts = true);
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 2)));
      final response = await dio.get(ApiConstants.getTopCriticalStocks);

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _criticalAlerts = response.data['top_critical_stocks'] ?? [];
            _isLoadingAlerts = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching critical alerts: $e");
      if (mounted) setState(() => _isLoadingAlerts = false);
    }
  }

  void _updateProgress(double details) {
    setState(() {
      _holdProgress += details;
      if (_holdProgress >= 1.0) {
        _holdProgress = 1.0;
        _isTransmitting = true;
        _triggerEmergencyBurst();
      }
    });
  }

  void _triggerEmergencyBurst() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'BURST TRANSMISSION SENT TO NCPOR',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.statusCritical,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 120, left: 24, right: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isTransmitting = false;
          _holdProgress = 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME AWARENESS ---
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceElevated;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;

    return Scaffold(
      // backgroundColor removed!
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                "Emergency Comms",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryText, letterSpacing: -0.5),
              ),
            ),

            // 1. SATCOM Status Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: isLight ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.statusNominal, 
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.statusNominal.withOpacity(isLight ? 0.2 : 0.8), blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("BURST CHANNEL: STANDBY", style: TextStyle(fontWeight: FontWeight.w800, color: primaryText, fontSize: 13, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text("SATCOM Link Established", style: TextStyle(fontSize: 12, color: secondaryText, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.satellite_alt_outlined, color: isLight ? Colors.black : secondaryText),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // 2. Primary SOS Button Area (High Contrast Drag Target)
            Center(
              child: GestureDetector(
                onPanUpdate: (details) => _updateProgress(details.delta.dx / 200),
                onPanEnd: (_) {
                  if (!_isTransmitting) setState(() => _holdProgress = 0.0);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Track
                    Container(
                      width: 280,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isLight ? const Color(0xFFE2E8F0) : surfaceColor,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: AppColors.statusCritical.withOpacity(isLight ? 0.6 : 0.3),
                          width: isLight ? 3 : 2,
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: Text(
                        "SLIDE TO TRANSMIT",
                        style: TextStyle(
                          color: isLight ? Colors.black54 : secondaryText, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1.2
                        ),
                      ),
                    ),

                    // Progress Fill
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 80 + (200 * _holdProgress),
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isTransmitting 
                              ? AppColors.statusCritical 
                              : AppColors.statusCritical.withOpacity(isLight ? 0.3 : 0.2),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),

                    // Draggable Button
                    Positioned(
                      left: 200 * _holdProgress,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.statusCritical,
                          shape: BoxShape.circle,
                          border: isLight ? Border.all(color: Colors.black, width: 2) : null,
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: _isTransmitting
                            ? const Icon(Icons.wifi_tethering, color: Colors.white, size: 36)
                            : const Icon(Icons.keyboard_double_arrow_right_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 56),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Active Local Alerts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaryText),
                  ),
                  if (_isLoadingAlerts)
                    const SizedBox(
                      width: 16, height: 16, 
                      child: CircularProgressIndicator(color: AppColors.statusCritical, strokeWidth: 2)
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Live Automated Local Alerts List
            Expanded(
              child: _isLoadingAlerts && _criticalAlerts.isEmpty
                  ? Center(child: Text("Scanning for anomalies...", style: TextStyle(color: secondaryText, fontWeight: FontWeight.w600)))
                  : _criticalAlerts.isEmpty
                      ? Center(child: Text("Station systems nominal. No active alerts.", style: TextStyle(color: AppColors.statusNominal, fontWeight: FontWeight.bold)))
                      : ListView.separated(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
                          itemCount: _criticalAlerts.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final alert = _criticalAlerts[index];
                            final bool isHighRisk = alert['criticality_status'] == 'HIGH';
                            
                            final String title = "Shortage: ${alert['name']}";
                            final String description = "Score: ${alert['criticality_rate']}. Only ${alert['present_stock']} units remaining. Lead time is ${alert['lead_time_days']} days.";
                            
                            String timeString = "Just now";
                            if (alert['updated_at'] != null && alert['updated_at'].toString().length >= 16) {
                              timeString = alert['updated_at'].toString().substring(11, 16);
                            }

                            return _buildAlertCard(
                              title: title,
                              description: description,
                              time: timeString,
                              icon: isHighRisk ? Icons.local_fire_department_outlined : Icons.warning_amber_rounded,
                              color: isHighRisk ? AppColors.statusCritical : AppColors.statusWarning,
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              isLight: isLight,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color color,
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isLight,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12), // Tactical 12px
        border: Border.all(
          color: isLight ? color : color.withOpacity(0.5), 
          width: isLight ? 2 : 1
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 11, color: secondaryText, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: primaryText, height: 1.4, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}