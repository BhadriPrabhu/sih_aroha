// lib/features/cargo/presentation/screens/cargo_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CargoDetailScreen extends StatelessWidget {
  const CargoDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME AWARENESS ---
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceElevated;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text("Shipment Details", style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.share_outlined, color: primaryText), onPressed: () {}),
          IconButton(icon: Icon(Icons.download_outlined, color: primaryText), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const AnimatedCargoShip(),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ID-SHP8942",
                    style: AppTypography.telemetry.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: primaryText),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: isLight ? Colors.black : AppColors.statusNominal),
                      const SizedBox(width: 4),
                      Text("Cape Town, SA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryText)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Custom Timeline (Theme injected)
              _buildRouteTimeline(isLight, primaryText, secondaryText, surfaceColor, borderColor),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: isLight ? 2 : 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.widgets_outlined, "Payload Weight", "1,850 kg", primaryText, secondaryText),
                    _buildDivider(borderColor, isLight),
                    _buildDetailRow(Icons.verified_outlined, "Status", "Crew Stop", primaryText, secondaryText, highlightColor: AppColors.statusWarning),
                    _buildDivider(borderColor, isLight),
                    _buildDetailRow(Icons.warning_amber_rounded, "Caution", "Severe Weather Expected", primaryText, secondaryText, highlightColor: AppColors.statusCritical),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              AnimatedTrackingButton(onPressed: () => context.push('/cargo/details/tracking')),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteTimeline(bool isLight, Color pText, Color sText, Color surface, Color border) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.polarCyan, shape: BoxShape.circle)),
            Expanded(child: Container(height: isLight ? 4 : 3, color: AppColors.polarCyan)),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.statusWarning.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.directions_boat_filled, size: 20, color: AppColors.statusWarning),
            ),
            Expanded(child: Container(height: isLight ? 4 : 3, color: border)),
            Container(width: 12, height: 12, decoration: BoxDecoration(color: surface, border: Border.all(color: border, width: isLight ? 3 : 2), shape: BoxShape.circle)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Goa", style: TextStyle(fontWeight: FontWeight.bold, color: pText)),
                Text("IND", style: TextStyle(fontSize: 12, color: sText)),
              ],
            ),
            Text("14 days ETA", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sText)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Bharati", style: TextStyle(fontWeight: FontWeight.bold, color: pText)),
                Text("ANT", style: TextStyle(fontSize: 12, color: sText)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color pText, Color sText, {Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: sText, size: 22),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: sText)),
          const Spacer(),
          if (highlightColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: highlightColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: highlightColor)),
            )
          else
            Text(value, style: AppTypography.telemetry.copyWith(fontSize: 15, fontWeight: FontWeight.bold, color: pText)),
        ],
      ),
    );
  }

  Widget _buildDivider(Color borderColor, bool isLight) {
    return Container(height: isLight ? 2 : 1, width: double.infinity, color: borderColor);
  }
}

class AnimatedCargoShip extends StatefulWidget {
  const AnimatedCargoShip({super.key});
  @override
  State<AnimatedCargoShip> createState() => _AnimatedCargoShipState();
}

class _AnimatedCargoShipState extends State<AnimatedCargoShip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bobAnimation;
  late Animation<double> _rockAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true);
    _bobAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
    _rockAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceElevated;
    final hullColor = isLight ? Colors.black : secondaryText;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 40, right: 60,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.statusCritical.withOpacity(0.8), boxShadow: [BoxShadow(color: AppColors.statusCritical.withOpacity(0.2), blurRadius: 12, spreadRadius: 4)]),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.translationValues(0, _bobAnimation.value, 0)..rotateZ(_rockAnimation.value),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildContainer(AppColors.polarCyan, 28, 32, surfaceColor),
                    const SizedBox(width: 2),
                    _buildContainer(AppColors.statusNominal, 40, 32, surfaceColor),
                    const SizedBox(width: 2),
                    _buildContainer(AppColors.polarCyan, 24, 32, surfaceColor),
                    const SizedBox(width: 4),
                    Container(
                      width: 24, height: 36,
                      decoration: BoxDecoration(color: hullColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Container(width: 12, height: 6, color: surfaceColor),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 150, height: 32,
                  decoration: BoxDecoration(color: hullColor, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(8), topLeft: Radius.circular(4))),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            child: Container(width: 190, height: 16, decoration: BoxDecoration(color: AppColors.polarCyan.withOpacity(0.15), borderRadius: BorderRadius.circular(8))),
          ),
          Positioned(
            bottom: 56,
            child: Container(width: 140, height: 12, decoration: BoxDecoration(color: AppColors.polarCyan.withOpacity(0.3), borderRadius: BorderRadius.circular(6))),
          ),
          Positioned(
            bottom: 16,
            child: Text("EXPEDITION RESUPPLY PAYLOAD", style: TextStyle(color: secondaryText, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.0)),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(Color color, double height, double width, Color surface) {
    return Container(
      height: height, width: width,
      decoration: BoxDecoration(color: color.withOpacity(0.9), borderRadius: BorderRadius.circular(4), border: Border.all(color: color, width: 1)),
      child: Center(child: Container(width: 1, height: double.infinity, color: surface.withOpacity(0.3))),
    );
  }
}

class AnimatedTrackingButton extends StatefulWidget {
  final VoidCallback onPressed;
  const AnimatedTrackingButton({super.key, required this.onPressed});
  @override
  State<AnimatedTrackingButton> createState() => _AnimatedTrackingButtonState();
}

class _AnimatedTrackingButtonState extends State<AnimatedTrackingButton> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceObsidian;

    return Container(
      width: double.infinity,
      height: 64, // Human Factors: Minimum 60px target
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? Colors.black : AppColors.statusNominal.withOpacity(0.5), width: isLight ? 3 : 1.5),
        boxShadow: [
          if (!isLight) BoxShadow(color: AppColors.statusNominal.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Container(color: surfaceColor),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scannerController,
                builder: (context, child) {
                  final slideValue = -1.5 + (_scannerController.value * 3.0);
                  return FractionalTranslation(
                    translation: Offset(slideValue, 0),
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.statusNominal.withOpacity(isLight ? 0.2 : 0.6),
                              AppColors.polarCyan.withOpacity(isLight ? 0.2 : 0.6),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                highlightColor: AppColors.statusNominal.withOpacity(0.2),
                splashColor: AppColors.polarCyan.withOpacity(0.3),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.radar, color: isLight ? Colors.black : AppColors.statusNominal, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        "LIVE TRACKING",
                        style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
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