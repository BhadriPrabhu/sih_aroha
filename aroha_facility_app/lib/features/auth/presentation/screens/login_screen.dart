// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: "Dr. Aarav Sharma");
  final TextEditingController _passwordController = TextEditingController(text: "mem-001");
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      "name": _nameController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
      final response = await dio.post(ApiConstants.login, data: payload);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Extract user data
        final userData = response.data['user'];
        
        // Save session locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userData['id']);
        await prefs.setString('user_name', userData['name']);
        await prefs.setString('user_role', userData['role']);
        await prefs.setString('station_id', userData['station_id']);
        await prefs.setBool('is_logged_in', true);

        if (!mounted) return;
        
        // Navigate to the main dashboard
        context.go('/inventory');
      } else {
        _showError("Login failed. Please check your credentials.");
      }
    } catch (e) {
      _showError("Network Error: Could not connect to station server.");
      print("Login Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Icon Area
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentCyan.withOpacity(0.15), 
                          blurRadius: 30, 
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Lottie.asset(
                      'assets/animations/satellite_globe.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Titles
                  const Text("AROHA", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  const Text("Polar Expedition Logistics System", style: TextStyle(fontSize: 14, color: AppColors.accentCyan, letterSpacing: 0.5)),
                  const SizedBox(height: 48),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _buildInputDecoration(
                      hint: "e.g., Dr. Aarav Sharma",
                      label: "Personnel Name",
                      icon: Icons.person_outline,
                    ),
                    validator: (value) => value == null || value.isEmpty ? "Name is required" : null,
                  ),
                  const SizedBox(height: 20),

                  // Password (ID) Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _buildInputDecoration(
                      hint: "Enter your Member ID",
                      label: "Member ID (Password)",
                      icon: Icons.badge_outlined,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? "Member ID is required" : null,
                  ),
                  const SizedBox(height: 48),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentMint,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 8,
                        shadowColor: AppColors.accentMint.withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 3))
                          : const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required String label, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentMint, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentRed, width: 1.5)),
    );
  }
}

class AnimatedArohaLogo extends StatefulWidget {
  const AnimatedArohaLogo({super.key});

  @override
  State<AnimatedArohaLogo> createState() => _AnimatedArohaLogoState();
}

class _AnimatedArohaLogoState extends State<AnimatedArohaLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 3-second continuous loop for the scanning and rotation effects
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accentMint.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentMint.withOpacity(0.2), 
            blurRadius: 24, 
            spreadRadius: 4,
          )
        ],
      ),
      child: ClipOval(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Calculates the up-and-down sweep of the scanner line
            final scanPosition = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;

            return Stack(
              alignment: Alignment.center,
              children: [
                // 1. Rotating Tactical Ring
                Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: CustomPaint(
                    size: const Size(90, 90),
                    painter: LoginEncryptionRingPainter(color: AppColors.accentCyan.withOpacity(0.4)),
                  ),
                ),
                
                // 2. Pulsing Core Snowflake
                Transform.scale(
                  scale: 0.9 + (0.1 * math.sin(_controller.value * 4 * math.pi)),
                  child: const Icon(
                    Icons.ac_unit_rounded, 
                    size: 44, 
                    color: AppColors.accentMint,
                  ),
                ),

                // 3. Sweeping Biometric Laser Line
                Positioned(
                  top: scanPosition * 100,
                  child: Container(
                    width: 100,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentCyan.withOpacity(0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 4. Laser Gradient Trail
                Positioned(
                  top: (scanPosition * 100) - 20,
                  child: Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.accentCyan.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Custom Painter for the rotating cryptographic border
class LoginEncryptionRingPainter extends CustomPainter {
  final Color color;
  LoginEncryptionRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const dashCount = 8;
    const dashLength = (2 * math.pi) / (dashCount * 2);

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * 2 * dashLength;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LoginEncryptionRingPainter oldDelegate) => false;
}