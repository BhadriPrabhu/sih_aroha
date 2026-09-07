// lib/features/movement/presentation/screens/member_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class MemberProfileScreen extends StatelessWidget {
  final Map<String, dynamic> memberData;

  const MemberProfileScreen({super.key, required this.memberData});

  @override
  Widget build(BuildContext context) {
    final String name = memberData['name'] ?? 'Unknown Personnel';
    final String role = memberData['role'] ?? 'Unassigned';
    final String teamId = memberData['teamid'] ?? 'No Team';
    final String activityStatus = memberData['activity_status'] ?? 'UNKNOWN';

    // UI Formatting for status
    Color statusColor = AppColors.textMuted;
    String statusText = "Unknown";
    
    if (activityStatus == 'ON_STATION') {
      statusColor = AppColors.accentMint;
      statusText = "Inside Base";
    } else if (activityStatus == 'FIELD_MISSION') {
      statusColor = AppColors.accentAmber;
      statusText = "In Field";
    } else if (activityStatus == 'MEDICAL_EVAC') {
      statusColor = AppColors.accentRed;
      statusText = "Evacuated";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text("Personnel Profile", style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Avatar & Name
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentCyan, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "$role • $teamId",
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Emergency Vitals Row
            Row(
              children: [
                Expanded(child: _buildVitalCard("Blood Group", "O+", Icons.bloodtype, AppColors.accentRed)), // Mocked - API doesn't provide this yet
                const SizedBox(width: 16),
                Expanded(child: _buildVitalCard("Status", statusText, Icons.nature_people, statusColor)),
              ],
            ),
            const SizedBox(height: 16),

            // Deep Dive Details
            _buildDetailSection(
              title: "System Registration",
              content: "ID: ${memberData['id']}\nLast Updated: ${memberData['updated_at']?.substring(0, 10) ?? 'N/A'}",
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            _buildDetailSection(
              title: "Emergency Contact (Base)",
              content: "Cmdr. Rajan (Radio Channel 4)\nClearance: Level 2",
              icon: Icons.headset_mic_outlined,
            ),
            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.radio),
                label: const Text("Initiate Direct Radio Comms"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceElevated,
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDetailSection({required String title, required String content, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text(content, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}