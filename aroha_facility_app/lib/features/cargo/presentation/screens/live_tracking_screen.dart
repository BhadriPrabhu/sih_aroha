// lib/features/cargo/presentation/screens/live_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LatLng _currentPosition = const LatLng(-45.0, 45.0);
  final LatLng _destination = const LatLng(-69.4, 76.1); 
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME AWARENESS ---
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceObsidian;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Theme-Aware Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 4.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            ),
            children: [
              TileLayer(
                // SWITCH BASEMAP BASED ON ALBEDO MODE
                urlTemplate: isLight 
                    ? 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.aroha.facility',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(points: [_currentPosition, _destination], color: borderColor, strokeWidth: isLight ? 4.0 : 3.0, isDotted: true),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _destination,
                    width: 60, height: 60,
                    child: Icon(Icons.location_on, color: isLight ? Colors.black : AppColors.statusNominal, size: 36),
                  ),
                  Marker(
                    point: _currentPosition,
                    width: 80, height: 80,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 30 + (30 * _pulseController.value),
                              height: 30 + (30 * _pulseController.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.polarCyan.withOpacity(1.0 - _pulseController.value),
                              ),
                            ),
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle, border: Border.all(color: AppColors.polarCyan, width: 2)),
                              child: Icon(Icons.directions_boat_filled, color: isLight ? Colors.black : AppColors.polarCyan, size: 18),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Top App Bar Overlay
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, bottom: 16, left: 16, right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [scaffoldBg.withOpacity(0.95), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: primaryText),
                    iconSize: 28, // Fitts's Law constraint
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text("SATCOM LIVE", style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.statusCritical.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.statusCritical, width: 1.5),
                    ),
                    child: const Text("LINK ACTIVE", style: TextStyle(color: AppColors.statusCritical, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0)),
                  )
                ],
              ),
            ),
          ),

          // 3. Tactical HUD Overlay (Bottom)
          Positioned(
            bottom: 40, left: 24, right: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(isLight ? 0.95 : 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isLight ? Colors.black : AppColors.borderActive, width: isLight ? 3 : 1.5),
                boxShadow: [BoxShadow(color: scaffoldBg.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("VESSEL: ICE-CLASS RESUPPLY", style: TextStyle(color: primaryText, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0)),
                      Icon(Icons.speed, color: isLight ? Colors.black : AppColors.polarCyan, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTelemetryData("LATITUDE", "45° 00' 00\" S", secondaryText, primaryText)),
                      Container(width: 1, height: 40, color: borderColor),
                      Expanded(child: Padding(padding: const EdgeInsets.only(left: 16.0), child: _buildTelemetryData("LONGITUDE", "45° 00' 00\" E", secondaryText, primaryText))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTelemetryData("SPEED", "14.2 KTS", secondaryText, AppColors.polarCyan)),
                      Container(width: 1, height: 40, color: borderColor),
                      Expanded(child: Padding(padding: const EdgeInsets.only(left: 16.0), child: _buildTelemetryData("HEADING", "185° S", secondaryText, primaryText))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryData(String label, String value, Color sText, Color valColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: sText, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.telemetry.copyWith(color: valColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}