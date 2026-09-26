// lib/features/auth/presentation/screens/login_screen.dart
import 'package:aroha_facility_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/api_constants.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(
    text: "Dr. Aarav Sharma",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "mem-001",
  );

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

    Map<String, dynamic>? userData;
    bool isOfflineMode = false;

    try {
      // 1. Attempt Live Server Authentication[cite: 18]
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 3)));

      // Note: Replace with your actual auth endpoint
      final response = await dio.post(
        'http://10.40.32.155:8080/api/v1/auth/login',
        data: payload,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        userData = response.data['user'] as Map<String, dynamic>;
      }
    } catch (e) {
      // 2. Offline Fallback (SATCOM Down)
      print("Live Auth Failed, switching to Offline Cache: $e");
      isOfflineMode = true;

      // We simulate the fallback data exactly as you requested[cite: 18]
      userData = {
        'id': 'id_12345',
        'name': payload['name'] ?? 'Test User',
        'role': 'Admin',
        'station_id': 'station_maitri',
      };
    }

    // 3. Process Authentication Result
    if (userData != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userData['id']);
      await prefs.setString('user_name', userData['name']);
      await prefs.setString('user_role', userData['role']);
      await prefs.setString('station_id', userData['station_id']);
      await prefs.setBool('is_logged_in', true);

      if (!mounted) return;

      if (isOfflineMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Satcom Down: Logged in via Local Cache',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            backgroundColor: AppColors.statusWarning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      context.go('/inventory'); // Route to the dashboard[cite: 18]
    } else {
      _showError("Login failed. Please check your credentials.");
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor:
            AppColors.statusCritical, // Updated to new token[cite: 18]
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
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
                          color: AppColors.polarCyan.withOpacity(
                            isLight ? 0.05 : 0.15,
                          ),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    // Keep Lottie if you have the asset, otherwise fallback to Icon
                    child: Lottie.asset(
                      'assets/animations/satellite_globe.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                            Icons.satellite_alt,
                            size: 80,
                            color: isLight ? Colors.black : AppColors.polarCyan,
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Titles (Inside LoginScreen)
                  Text(
                    "AROHA",
                    style: TextStyle(
                      fontFamily: AppTypography.logoFont, // Applied Fraunces
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Polar Expedition Logistics System",
                    style: AppTypography.label.copyWith(
                      color: AppColors.polarCyan,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      fontFamily: AppTypography.primaryFont, // Applied Inter
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _buildInputDecoration(
                      hint: "e.g., Dr. Aarav Sharma",
                      label: "Personnel Name",
                      icon: Icons.person_outline,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      secondaryText: secondaryText,
                      isLight: isLight,
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Name is required"
                                : null,
                  ),
                  const SizedBox(height: 24),

                  // Password (ID) Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      fontFamily:
                          AppTypography.monoFont, // Applied JetBrains Mono for passcodes
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                      letterSpacing:
                          2.0, // Widen the hidden dots/text for readability
                    ),
                    decoration: _buildInputDecoration(
                      hint: "Enter your Member ID",
                      label: "Member ID (Password)",
                      icon: Icons.badge_outlined,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      secondaryText: secondaryText,
                      isLight: isLight,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color:
                              isLight
                                  ? secondaryText
                                  : AppColors.polarCyan.withOpacity(0.7),
                        ),
                        onPressed:
                            () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Member ID is required"
                                : null,
                  ),
                  const SizedBox(
                    height: 40,
                  ), // Increased breathing room before the button
                  // Login Button (OLED Glowing effect)
                  Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          isLight
                              ? []
                              : [
                                BoxShadow(
                                  color: AppColors.polarCyan.withOpacity(0.25),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isLight ? Colors.black : AppColors.polarCyan,
                        foregroundColor:
                            isLight
                                ? Colors.white
                                : AppColors
                                    .canvasBlack, // Deep black text on bright cyan
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 3,
                                ),
                              )
                              : const Text(
                                "INITIALIZE SYSTEM",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  // letterSpacing: 1.5,
                                  fontFamily: AppTypography.primaryFont
                                ),
                              ),
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

  InputDecoration _buildInputDecoration({
    required String hint,
    required String label,
    required IconData icon,
    required Color surfaceColor,
    required Color borderColor,
    required Color secondaryText,
    required bool isLight,
  }) {
    // OLED pure black fill for dark mode
    final oledFillColor = isLight ? surfaceColor : Colors.black;
    final oledBorderColor = isLight ? borderColor : Colors.white24;

    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: TextStyle(color: secondaryText.withOpacity(0.4)),
      labelStyle: TextStyle(
        color: isLight ? secondaryText : Colors.grey[400],
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: isLight ? secondaryText : AppColors.polarCyan,
      ),
      filled: true,
      fillColor: oledFillColor,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ), // More luxurious height
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: oledBorderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.polarCyan, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.statusCritical, width: 2),
      ),
    );
  }
}

// Custom Painter for the rotating cryptographic border[cite: 18]
class LoginEncryptionRingPainter extends CustomPainter {
  final Color color;
  LoginEncryptionRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
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
