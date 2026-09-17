// lib/features/movement/presentation/screens/member_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class MemberProfileScreen extends StatelessWidget {
  final Map<String, dynamic> memberData;

  const MemberProfileScreen({super.key, required this.memberData});

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME AWARENESS ---
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceObsidian;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;

    final String name = memberData['name'] ?? 'Unknown Personnel';
    final String role = memberData['role'] ?? 'Unassigned';
    final String teamId = memberData['teamid'] ?? 'No Team';
    final String activityStatus = memberData['activity_status'] ?? 'UNKNOWN';

    Color statusColor = AppColors.textMeta;
    String statusText = "Unknown";
    
    if (activityStatus == 'ON_STATION') {
      statusColor = AppColors.statusNominal;
      statusText = "INSIDE BASE";
    } else if (activityStatus == 'FIELD_MISSION') {
      statusColor = AppColors.statusWarning;
      statusText = "IN FIELD";
    } else if (activityStatus == 'MEDICAL_EVAC') {
      statusColor = AppColors.statusCritical;
      statusText = "EVACUATED";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text("Personnel Profile", style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Avatar & Name
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: isLight ? Colors.black : AppColors.polarCyan, width: isLight ? 4 : 2),
                boxShadow: isLight ? [] : [BoxShadow(color: AppColors.polarCyan.withOpacity(0.3), blurRadius: 20)],
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: isLight ? Colors.black : AppColors.polarCyan),
              ),
            ),
            const SizedBox(height: 16),
            Text(name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: primaryText), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text("${role.toUpperCase()}  •  $teamId", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: secondaryText, letterSpacing: 0.5), textAlign: TextAlign.center),
            const SizedBox(height: 32),

            // Emergency Vitals Row
            Row(
              children: [
                Expanded(child: _buildVitalCard("BLOOD TYPE", "O+", Icons.bloodtype, AppColors.statusCritical, surfaceColor, borderColor, primaryText, secondaryText, isLight)),
                const SizedBox(width: 16),
                Expanded(child: _buildVitalCard("LOCATION", statusText, Icons.my_location, statusColor, surfaceColor, borderColor, primaryText, secondaryText, isLight)),
              ],
            ),
            const SizedBox(height: 16),

            // Deep Dive Details
            _buildDetailSection(
              title: "SYSTEM REGISTRATION",
              content: "ID: ${memberData['id']}\nUPDATED: ${memberData['updated_at']?.substring(0, 10) ?? 'N/A'}",
              icon: Icons.badge_outlined,
              surfaceColor: surfaceColor, borderColor: borderColor, primaryText: primaryText, secondaryText: secondaryText, isLight: isLight
            ),
            const SizedBox(height: 16),
            _buildDetailSection(
              title: "EMERGENCY CONTACT (BASE)",
              content: "Cmdr. Rajan (Radio Channel 4)\nClearance: Level 2",
              icon: Icons.headset_mic_outlined,
              surfaceColor: surfaceColor, borderColor: borderColor, primaryText: primaryText, secondaryText: secondaryText, isLight: isLight
            ),
            const SizedBox(height: 48),

            // Human Factors: Action Button
            // Human Factors: Action Button
            SizedBox(
              width: double.infinity,
              height: 64, // Minimum 60px target for gloved interaction
              child: ElevatedButton(
                onPressed: () {
                  // --- NEW: Trigger the Tactical PTT Modal ---
                  _showRadioCommsModal(
                    context, 
                    name, 
                    isLight, 
                    surfaceColor, 
                    borderColor, 
                    primaryText, 
                    secondaryText
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLight ? Colors.black : AppColors.surfaceElevated,
                  foregroundColor: isLight ? Colors.white : AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isLight ? Colors.black : AppColors.polarCyan.withOpacity(0.5), width: 2),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.radio, color: isLight ? Colors.white : AppColors.polarCyan, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      "INITIATE RADIO COMMS", 
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: isLight ? Colors.white : AppColors.textPrimary)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showRadioCommsModal(
    BuildContext context, 
    String name, 
    bool isLight, 
    Color surfaceColor, 
    Color borderColor, 
    Color primaryText, 
    Color secondaryText
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        bool isTransmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: borderColor, width: isLight ? 3 : 1),
                  left: BorderSide(color: borderColor, width: isLight ? 3 : 1),
                  right: BorderSide(color: borderColor, width: isLight ? 3 : 1),
                ),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(color: secondaryText.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
                  ),
                  
                  // Status Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SECURE SATCOM LINK", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: secondaryText, letterSpacing: 1.0)),
                          const SizedBox(height: 4),
                          Text(name.toUpperCase(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryText)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isTransmitting ? AppColors.statusCritical : AppColors.statusNominal).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: isTransmitting ? AppColors.statusCritical : AppColors.statusNominal, width: 1.5),
                        ),
                        child: Text(
                          isTransmitting ? "TX ACTIVE" : "LINK OPEN", 
                          style: TextStyle(
                            color: isTransmitting ? AppColors.statusCritical : AppColors.statusNominal, 
                            fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0
                          )
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Telemetry Divider
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.symmetric(horizontal: BorderSide(color: borderColor, width: isLight ? 2 : 1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("FREQ: 156.800 MHz", style: AppTypography.telemetry.copyWith(color: AppColors.polarCyan, fontSize: 14)),
                        Container(width: 1, height: 20, color: borderColor),
                        Text("CHAN: 16 (VHF)", style: AppTypography.telemetry.copyWith(color: AppColors.polarCyan, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Massive PTT Button (Fitts's Law)
                  GestureDetector(
                    onTapDown: (_) => setState(() => isTransmitting = true),
                    onTapUp: (_) => setState(() => isTransmitting = false),
                    onTapCancel: () => setState(() => isTransmitting = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: double.infinity,
                      height: 120, // Giant target area
                      decoration: BoxDecoration(
                        color: isTransmitting 
                            ? AppColors.statusCritical 
                            : (isLight ? Colors.black : AppColors.surfaceElevated),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isTransmitting 
                              ? AppColors.statusCritical 
                              : (isLight ? Colors.black : AppColors.polarCyan.withOpacity(0.5)), 
                          width: isLight ? 4 : 2
                        ),
                        boxShadow: isTransmitting ? [
                          BoxShadow(color: AppColors.statusCritical.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)
                        ] : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic, 
                            color: isTransmitting ? Colors.white : (isLight ? Colors.white : AppColors.polarCyan), 
                            size: 40
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isTransmitting ? "TRANSMITTING..." : "HOLD TO SPEAK",
                            style: TextStyle(
                              color: isTransmitting ? Colors.white : (isLight ? Colors.white : primaryText),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color, Color surface, Color border, Color pText, Color sText, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: isLight ? 2 : 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isLight ? Colors.black : color, letterSpacing: 0.5), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: sText, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  Widget _buildDetailSection({required String title, required String content, required IconData icon, required Color surfaceColor, required Color borderColor, required Color primaryText, required Color secondaryText, required bool isLight}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isLight ? 2 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: secondaryText, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: secondaryText, letterSpacing: 1.0)),
                const SizedBox(height: 8),
                Text(content, style: AppTypography.telemetry.copyWith(fontSize: 14, color: primaryText, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}