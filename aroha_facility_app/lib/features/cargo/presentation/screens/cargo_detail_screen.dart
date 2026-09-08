// lib/features/cargo/presentation/screens/cargo_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class CargoDetailScreen extends StatelessWidget {
  const CargoDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Shipment Details",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
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
                  const Text(
                    "ID-SHP8942",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.accentMint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Cape Town, SA",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Custom Timeline
              _buildRouteTimeline(),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Details List
                    _buildDetailRow(
                      Icons.widgets_outlined,
                      "Payload Weight",
                      "1,850 kg",
                    ),
                    _buildDivider(),
                    _buildDetailRow(
                      Icons.verified_outlined,
                      "Status",
                      "Crew Stop",
                      highlightColor: AppColors.accentAmber,
                    ),
                    _buildDivider(),
                    // _buildDetailRow(
                    //   Icons.chat_bubble_outline,
                    //   "Comments",
                    //   "Awaiting Icebreaker Escort",
                    // ),
                    // _buildDivider(),
                    _buildDetailRow(
                      Icons.warning_amber_rounded,
                      "Caution",
                      "Severe Weather Expected",
                      highlightColor: AppColors.accentRed,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              AnimatedTrackingButton(
                onPressed: () => context.push('/cargo/details/tracking'),
              ),
              // const SizedBox(height: 12),

              // 3. Single Action Button
              // SizedBox(
              //   width: double.infinity,
              //   height: 48,
              //   child: ElevatedButton(
              //     onPressed: () {},
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.textPrimary,
              //       foregroundColor: AppColors.background,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //     child: const Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(Icons.location_pin, color: Colors.black, size: 24,),
              //         SizedBox(width: 6,),
              //         Text(
              //           "LIVE TRACKING",
              //           style: TextStyle(
              //             fontSize: 20,
              //             fontWeight: FontWeight.w800,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  // --- Route Timeline Builder ---
  Widget _buildRouteTimeline() {
    return Column(
      children: [
        Row(
          children: [
            // Origin Dot
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.accentCyan,
                shape: BoxShape.circle,
              ),
            ),
            // Solid Line to Stop
            Expanded(child: Container(height: 3, color: AppColors.accentCyan)),
            // Stop Icon (Current Location)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentAmber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_boat_filled,
                size: 20,
                color: AppColors.accentAmber,
              ),
            ),
            // Dashed Line to Destination (mocked with simple container for now)
            Expanded(child: Container(height: 3, color: AppColors.cardBorder)),
            // Destination Dot
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.cardBorder, width: 2),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Goa",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "IND",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              "14 days ETA",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Bharati",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "ANT",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? highlightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
          const Spacer(),
          if (highlightColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: highlightColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: highlightColor,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: AppColors.cardBorder,
    );
  }
}

class AnimatedCargoShip extends StatefulWidget {
  const AnimatedCargoShip({super.key});

  @override
  State<AnimatedCargoShip> createState() => _AnimatedCargoShipState();
}

class _AnimatedCargoShipState extends State<AnimatedCargoShip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bobAnimation;
  late Animation<double> _rockAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Up and down bobbing motion
    _bobAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    // Slight left-to-right rocking motion
    _rockAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Background Element (OLED Sun/Moon)
          Positioned(
            top: 40,
            right: 60,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentRed.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentRed.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // 2. The Animated Ship
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.translationValues(0, _bobAnimation.value, 0)
                  ..rotateZ(_rockAnimation.value),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top layer: Containers and Bridge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildContainer(AppColors.accentCyan, 28, 32),
                    const SizedBox(width: 2),
                    _buildContainer(AppColors.accentMint, 40, 32),
                    const SizedBox(width: 2),
                    _buildContainer(AppColors.accentCyan, 24, 32),
                    const SizedBox(width: 4),
                    // Ship Bridge (Cabin)
                    Container(
                      width: 24,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          // Tiny window
                          Container(
                            width: 12,
                            height: 6,
                            color: AppColors.surfaceElevated,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Bottom layer: Hull
                Container(
                  width: 150,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(8),
                      topLeft: Radius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Foreground Waves
          Positioned(
            bottom: 50,
            child: Container(
              width: 190,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            bottom: 56,
            child: Container(
              width: 140,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          // 4. Label Overlay
          const Positioned(
            bottom: 16,
            child: Text(
              "Expedition Resupply Payload",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(Color color, double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      // Container ridge detailing
      child: Center(
        child: Container(
          width: 1,
          height: double.infinity,
          color: AppColors.surfaceElevated.withOpacity(0.3),
        ),
      ),
    );
  }
}

class AnimatedTrackingButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedTrackingButton({super.key, required this.onPressed});

  @override
  State<AnimatedTrackingButton> createState() => _AnimatedTrackingButtonState();
}

class _AnimatedTrackingButtonState extends State<AnimatedTrackingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    // Creates a continuous 2-second looping animation
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Outer glowing border
        border: Border.all(
          color: AppColors.accentMint.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentMint.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          18,
        ), // Slightly less than the container to fit inside the border
        child: Stack(
          children: [
            // 1. OLED Deep Dark Base
            Container(color: AppColors.surface),

            // 2. Animated Tactical Scanner Beam
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scannerController,
                builder: (context, child) {
                  // Moves the beam from offscreen left (-1.5) to offscreen right (1.5)
                  final slideValue = -1.5 + (_scannerController.value * 3.0);

                  return FractionalTranslation(
                    translation: Offset(slideValue, 0),
                    child: FractionallySizedBox(
                      widthFactor:
                          0.5, // The beam takes up 50% of the button width
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.accentMint.withOpacity(0.6),
                              AppColors.accentCyan.withOpacity(0.6),
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

            // 3. Interactive Foreground Layer (Text & Icon)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                highlightColor: AppColors.accentMint.withOpacity(0.2),
                splashColor: AppColors.accentCyan.withOpacity(0.3),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.radar, color: AppColors.accentMint, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "LIVE TRACKING",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
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
