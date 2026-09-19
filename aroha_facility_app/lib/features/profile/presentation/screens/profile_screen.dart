// lib/features/profile/presentation/screens/profile_screen.dart
import 'dart:math';
import 'dart:ui';
import 'package:aroha_facility_app/core/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final String _userName = "Dr. Aarav Sharma";
  final String _userRole = "Lead Glaciologist";
  final String _memberId = "mem-001";
  
  bool _isOutsideStation = false;

  // Animation Controllers
  late AnimationController _radarController;
  late AnimationController _chartEntryController;
  late AnimationController _vitalsController;

  @override
  void initState() {
    super.initState();
    // 1. Radar sweep rotation for the avatar
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 2. Entry animation for the telemetry rings
    _chartEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // 3. Continuous ECG/Vitals wave animation
    _vitalsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _chartEntryController.dispose();
    _vitalsController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    context.go('/login');
  }

  void _toggleStatus(bool isOutside) {
    if (_isOutsideStation == isOutside) return;
    setState(() {
      _isOutsideStation = isOutside;
      // Change vitals animation speed based on status (faster when outside)
      _vitalsController.duration = Duration(milliseconds: isOutside ? 600 : 1200);
      _vitalsController.repeat();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isOutside ? 'Status updated: FIELD MISSION' : 'Status updated: ON STATION',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isOutside ? AppColors.accentAmber : AppColors.accentMint,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 120, left: 24, right: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Read the current theme context dynamically
    final isLight = Theme.of(context).brightness == Brightness.light;
    
    // 2. Extract the dynamic colors from our AppTheme
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceElevated;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.borderHairline;
    
    final statusColor = _isOutsideStation ? AppColors.statusWarning : AppColors.polarCyan;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: TacticalGridPainter(
              color: primaryText.withOpacity(isLight ? 0.2 : 0.08)
            )),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Personnel Profile", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryText)),
                  const SizedBox(height: 32),

                  // 1. Animated Radar Avatar & Vitals
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _radarController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _radarController.value * 2 * pi,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              CustomPaint(
                                size: const Size(130, 130),
                                painter: TacticalBorderPainter(color: statusColor),
                              ),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: surfaceColor, // Dynamic
                                  shape: BoxShape.circle,
                                  border: Border.all(color: statusColor, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _userName[0],
                                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(_userName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryText)), // Dynamic
                        const SizedBox(height: 4),
                        Text("$_userRole  •  $_memberId", style: TextStyle(fontSize: 14, color: secondaryText)), // Dynamic
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. High-Tech Sliding Segmented Toggle
                  Text("Operational Status", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: secondaryText)), // Dynamic
                  const SizedBox(height: 12),
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: surfaceColor, // Dynamic
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: borderColor, width: isLight ? 2 : 1), // Dynamic
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          top: 4,
                          bottom: 4,
                          left: _isOutsideStation ? MediaQuery.of(context).size.width / 2 - 28 : 4,
                          right: _isOutsideStation ? 4 : MediaQuery.of(context).size.width / 2 - 28,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isOutsideStation ? AppColors.statusWarning.withOpacity(0.15) : AppColors.statusNominal.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: _isOutsideStation ? AppColors.statusWarning.withOpacity(0.5) : AppColors.statusNominal.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _toggleStatus(false),
                                behavior: HitTestBehavior.opaque,
                                child: Center(
                                  child: Text("ON STATION", style: TextStyle(fontWeight: FontWeight.bold, color: !_isOutsideStation ? AppColors.statusNominal : secondaryText)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _toggleStatus(true),
                                behavior: HitTestBehavior.opaque,
                                child: Center(
                                  child: Text("FIELD MISSION", style: TextStyle(fontWeight: FontWeight.bold, color: _isOutsideStation ? AppColors.statusWarning : secondaryText)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Glowing Concentric Telemetry Rings
                  Text("Activity Telemetry", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: secondaryText)), // Dynamic
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceColor, // Dynamic
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: isLight ? 2 : 1), // Dynamic
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: AnimatedBuilder(
                            animation: _chartEntryController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: ConcentricRingsPainter(
                                  progress: _chartEntryController.value,
                                  ring1Value: 0.85,
                                  ring2Value: 0.65,
                                  ring3Value: 0.40,
                                  bgColor: isLight ? const Color(0xFFE2E8F0) : AppColors.surfaceElevated, // Dynamic Ring Track
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem("Efficiency", "85%", AppColors.polarCyan, secondaryText),
                              const SizedBox(height: 16),
                              _buildLegendItem("Station Hrs", "65%", AppColors.statusNominal, secondaryText),
                              const SizedBox(height: 16),
                              _buildLegendItem("Field Hrs", "40%", AppColors.statusWarning, secondaryText),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Terminal Settings
                  Text("Terminal Settings", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: secondaryText)), // Dynamic
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor, // Dynamic
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: isLight ? 2 : 1), // Dynamic
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("High-Albedo Mode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText)), // Dynamic
                            const SizedBox(height: 4),
                            Text("Max contrast for snow blindness", style: TextStyle(fontSize: 12, color: secondaryText)), // Dynamic
                          ],
                        ),
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: ThemeNotifier.themeMode, // Defined in your notifier[cite: 8]
                          builder: (context, currentMode, child) {
                            final isHighAlbedo = currentMode == ThemeMode.light;
                            return Switch(
                              value: isHighAlbedo,
                              onChanged: ThemeNotifier.toggleTheme,
                              activeColor: AppColors.canvasBlack,
                              activeTrackColor: AppColors.polarCyan,
                              inactiveThumbColor: AppColors.textMeta,
                              inactiveTrackColor: AppColors.surfaceElevated,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => context.push('/sync'), // Route to the new Sync Screen
                      style: ElevatedButton.styleFrom(
                        backgroundColor: surfaceColor,
                        foregroundColor: primaryText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isLight ? Colors.black : AppColors.polarCyan.withOpacity(0.5), width: isLight ? 2 : 1),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sync, color: isLight ? Colors.black : AppColors.polarCyan, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "DATA UPLINK & SYNC", 
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: primaryText)
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Logout Button
                  AnimatedHazardButton(onPressed: _handleLogout),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color iconColor, Color textColor) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: iconColor.withOpacity(0.5), blurRadius: 2)]),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(color: textColor, fontSize: 13))), // Dynamic text color
        Text(value, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

// --- CUSTOM PAINTERS & WIDGETS ---

class AnimatedHazardButton extends StatefulWidget {
  final VoidCallback onPressed;
  const AnimatedHazardButton({super.key, required this.onPressed});

  @override
  State<AnimatedHazardButton> createState() => _AnimatedHazardButtonState();
}

class _AnimatedHazardButtonState extends State<AnimatedHazardButton> with SingleTickerProviderStateMixin {
  late AnimationController _stripeController;

  @override
  void initState() {
    super.initState();
    _stripeController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _stripeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentRed.withOpacity(0.8), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.accentRed.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Container(color: AppColors.surface), // Base Dark
            // Button Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                // highlightColor: AppColors.accentRed.withOpacity(0.2),
                // splashColor: AppColors.accentRed.withOpacity(0.4),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: AppColors.accentRed, size: 24),
                      SizedBox(width: 12),
                      Text("LOGOUT", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
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

class WarningStripePainter extends CustomPainter {
  final double offset;
  WarningStripePainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentRed.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    const stripeWidth = 20.0;
    const spacing = 40.0;
    // Shift pattern based on animation value
    final shift = offset * spacing;

    for (double i = -size.height; i < size.width; i += spacing) {
      final path = Path()
        ..moveTo(i + shift, 0)
        ..lineTo(i + stripeWidth + shift, 0)
        ..lineTo(i - size.height + stripeWidth + shift, size.height)
        ..lineTo(i - size.height + shift, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WarningStripePainter oldDelegate) => true;
}

class TacticalGridPainter extends CustomPainter {
  final Color color;
  TacticalGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const double spacing = 30.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1.0, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant TacticalGridPainter oldDelegate) => true;
}

class ConcentricRingsPainter extends CustomPainter {
  final double progress;
  final double ring1Value;
  final double ring2Value;
  final double ring3Value;
  final Color bgColor;

  ConcentricRingsPainter({required this.progress, required this.ring1Value, required this.ring2Value, required this.ring3Value, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;
    const spacing = 14.0;

    void drawRing(double radius, double value, Color color) {
      final bgPaint = Paint()..color =  bgColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, bgPaint);

      final sweepAngle = 2 * pi * (value * progress);
      final fgPaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle, false, fgPaint);
    }

    final r1 = size.width / 2 - (strokeWidth / 2);
    final r2 = r1 - spacing;
    final r3 = r2 - spacing;

    drawRing(r1, ring1Value, AppColors.accentCyan);
    drawRing(r2, ring2Value, AppColors.accentMint);
    drawRing(r3, ring3Value, AppColors.accentAmber);
  }
  @override
  bool shouldRepaint(covariant ConcentricRingsPainter oldDelegate) => true;
}

class TacticalBorderPainter extends CustomPainter {
  final Color color;
  TacticalBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const dashCount = 12;
    const dashLength = (2 * pi) / (dashCount * 2);

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * 2 * dashLength;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, dashLength, false, paint);
    }
  }
  @override
  bool shouldRepaint(covariant TacticalBorderPainter oldDelegate) => true;
}