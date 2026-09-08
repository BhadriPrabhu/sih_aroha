// lib/features/emergency/presentation/screens/emergency_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart'; // Ensure this path matches your project

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  bool _isTransmitting = false;
  double _holdProgress = 0.0;
  
  // API State
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
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
      // Call the top-critical endpoint
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
    // TODO: Connect to Drogon /emergency-alert endpoint
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'BURST TRANSMISSION SENT TO NCPOR',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating, // Makes it float instead of sticking to the bottom
        margin: const EdgeInsets.only(bottom: 120, left: 24, right: 24), // Clears the custom nav bar
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
      ),
    );

    // Reset after a delay
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                "Emergency Comms",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // 1. SATCOM Status Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.accentMint, // Indicates connection is available
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.accentMint, blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Burst Channel: STANDBY",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          "SATCOM Link Established",
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.satellite_alt_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. Primary SOS Button Area
            Center(
              child: GestureDetector(
                onPanUpdate: (details) => _updateProgress(details.delta.dx / 200), // Slide right to trigger
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
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: AppColors.accentRed.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Text(
                        "SLIDE TO TRANSMIT",
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),

                    // Progress Fill
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 80 + (200 * _holdProgress),
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isTransmitting ? AppColors.accentRed : AppColors.accentRed.withOpacity(0.2),
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
                        decoration: const BoxDecoration(
                          color: AppColors.accentRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: _isTransmitting
                            ? const Icon(Icons.wifi_tethering, color: AppColors.background, size: 36)
                            : const Icon(Icons.arrow_forward_rounded, color: AppColors.background, size: 36),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Active Local Alerts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  if (_isLoadingAlerts)
                    const SizedBox(
                      width: 16, height: 16, 
                      child: CircularProgressIndicator(color: AppColors.accentRed, strokeWidth: 2)
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Live Automated Local Alerts List
            Expanded(
              child: _isLoadingAlerts && _criticalAlerts.isEmpty
                  ? const Center(child: Text("Scanning for anomalies...", style: TextStyle(color: AppColors.textSecondary)))
                  : _criticalAlerts.isEmpty
                      ? const Center(child: Text("Station systems nominal. No active alerts.", style: TextStyle(color: AppColors.accentMint)))
                      : ListView.separated(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120), // 120px padding for bottom nav
                          itemCount: _criticalAlerts.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final alert = _criticalAlerts[index];
                            final bool isHighRisk = alert['criticality_status'] == 'HIGH';
                            
                            // Map the API data to the UI text
                            final String title = "Shortage Alert: ${alert['name']}";
                            final String description = "Score: ${alert['criticality_rate']}. Only ${alert['present_stock']} units remaining. Lead time is ${alert['lead_time_days']} days.";
                            
                            // Extract time safely
                            String timeString = "Just now";
                            if (alert['updated_at'] != null && alert['updated_at'].toString().length >= 16) {
                              timeString = alert['updated_at'].toString().substring(11, 16);
                            }

                            return _buildAlertCard(
                              title: title,
                              description: description,
                              time: timeString,
                              icon: isHighRisk ? Icons.local_fire_department_outlined : Icons.warning_amber_rounded,
                              color: isHighRisk ? AppColors.accentRed : AppColors.accentAmber,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
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
                        title,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}