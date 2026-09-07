// lib/features/movement/presentation/screens/member_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key});

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
              child: const Text(
                "A",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Dr. Aravind S.",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              "Medical Officer • Expedition Alpha",
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Emergency Vitals Row
            Row(
              children: [
                Expanded(child: _buildVitalCard("Blood Group", "O+", Icons.bloodtype, AppColors.accentRed)),
                const SizedBox(width: 16),
                Expanded(child: _buildVitalCard("Status", "Outside", Icons.nature_people, AppColors.accentAmber)),
              ],
            ),
            const SizedBox(height: 16),

            // Deep Dive Details
            _buildDetailSection(
              title: "Current Location",
              content: "Grid Sector 4B - Glacier Observation Point\nLast ping: 14 mins ago",
              icon: Icons.location_on_outlined,
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
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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