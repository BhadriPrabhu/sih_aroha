// lib/features/cargo/presentation/screens/live_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  
  // Current mocked position of the ship (Southern Indian Ocean)
  final LatLng _currentPosition = const LatLng(-45.0, 45.0);
  final LatLng _destination = const LatLng(-69.4, 76.1); // Bharati Station
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. The Lightweight Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 4.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              // Dark Mode OLED Tiles (CartoDB Dark Matter)
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.aroha.facility',
              ),
              // Route Line
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_currentPosition, _destination],
                    color: AppColors.cardBorder,
                    strokeWidth: 3.0,
                    isDotted: true,
                  ),
                ],
              ),
              // Ship & Destination Markers
              MarkerLayer(
                markers: [
                  // Destination Marker
                  Marker(
                    point: _destination,
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.location_on, color: AppColors.accentMint, size: 32),
                  ),
                  // Animated Ship Marker
                  Marker(
                    point: _currentPosition,
                    width: 80,
                    height: 80,
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
                                color: AppColors.accentCyan.withOpacity(1.0 - _pulseController.value),
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceElevated,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.directions_boat_filled, color: AppColors.accentCyan, size: 20),
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
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, bottom: 16, left: 16, right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.background.withOpacity(0.9), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text("SATCOM Live Feed", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentRed.withOpacity(0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: AppColors.accentRed, size: 10),
                        SizedBox(width: 6),
                        Text("LIVE", style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // 3. Tactical HUD Overlay (Bottom)
          Positioned(
            bottom: 100,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.accentCyan.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.background.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Vessel: Ice-Class Resupply", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      Icon(Icons.speed, color: AppColors.accentCyan, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTelemetryData("LATITUDE", "45° 00' 00\" S"),
                      ),
                      Container(width: 1, height: 40, color: AppColors.cardBorder),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: _buildTelemetryData("LONGITUDE", "45° 00' 00\" E"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTelemetryData("SPEED", "14.2 Knots"),
                      ),
                      Container(width: 1, height: 40, color: AppColors.cardBorder),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: _buildTelemetryData("HEADING", "185° South"),
                        ),
                      ),
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

  Widget _buildTelemetryData(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.accentMint, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }
}