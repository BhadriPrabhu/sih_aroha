// lib/features/movement/presentation/screens/movement_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';

class MovementScreen extends StatefulWidget {
  const MovementScreen({super.key});

  @override
  State<MovementScreen> createState() => _MovementScreenState();
}

class _MovementScreenState extends State<MovementScreen> {
  List<dynamic> _teams = [];
  List<dynamic> _members = [];
  
  bool _isLoadingTeams = true;
  bool _isLoadingMembers = true;
  
  String _selectedTeamId = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchTeamsAndInitialMembers();
  }

  Future<void> _fetchTeamsAndInitialMembers() async {
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
      
      // Fetch teams and all members concurrently
      final responses = await Future.wait([
        dio.get(ApiConstants.getTeams),
        dio.get(ApiConstants.getMembers),
      ]);

      if (mounted) {
        setState(() {
          // Inject 'All Members' as the first virtual team
          _teams = [
            {'teamid': 'ALL', 'teamname': 'All Members'}
          ];
          
          if (responses[0].statusCode == 200) {
            _teams.addAll(responses[0].data['teams'] ?? []);
          }
          
          if (responses[1].statusCode == 200) {
            _members = responses[1].data['members'] ?? [];
          }
          
          _isLoadingTeams = false;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      print("Error fetching movement data: $e");
      if (mounted) {
        setState(() {
          _isLoadingTeams = false;
          _isLoadingMembers = false;
        });
      }
    }
  }

  Future<void> _fetchMembersForTeam(String teamId) async {
    setState(() {
      _selectedTeamId = teamId;
      _isLoadingMembers = true;
    });

    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
      final url = teamId == 'ALL' 
          ? ApiConstants.getMembers 
          : ApiConstants.getTeamMembers(teamId);
          
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _members = response.data['members'] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching members for team $teamId: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingMembers = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                "Personnel Movement",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
            
            // 1. Group Selector (Instagram Stories Style)
            SizedBox(
              height: 100,
              child: _isLoadingTeams 
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentMint))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: _teams.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final team = _teams[index];
                      final isSelected = _selectedTeamId == team['teamid'];
                      final String displayName = team['teamname'] ?? 'Unknown';
                      final String avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

                      return GestureDetector(
                        onTap: () => _fetchMembersForTeam(team['teamid']),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.accentMint : AppColors.cardBorder,
                                  width: isSelected ? 3 : 1,
                                ),
                                color: AppColors.surfaceElevated,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                avatarLetter,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.accentMint : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayName.length > 10 ? '${displayName.substring(0, 8)}...' : displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
            
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text("Members", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ),

            // 2. Member Grid Layer (2 per row)
            Expanded(
              child: _isLoadingMembers 
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentCyan))
                : _members.isEmpty 
                  ? const Center(child: Text("No personnel found", style: TextStyle(color: AppColors.textSecondary)))
                  : GridView.builder(
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final member = _members[index];
                        return _buildMemberTile(
                          memberData: member,
                          // PASS THE LIVE DATA TO THE PROFILE SCREEN
                          onTap: () => context.push('/movement/profile', extra: member),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile({required Map<String, dynamic> memberData, required VoidCallback onTap}) {
    final String name = memberData['name'] ?? 'Unknown';
    final String role = memberData['role'] ?? 'No Role';
    final String activityStatus = memberData['activity_status'] ?? 'UNKNOWN';

    // Map API status to UI styling
    Color statusColor = AppColors.textMuted;
    String statusText = activityStatus.replaceAll('_', ' ');

    if (activityStatus == 'ON_STATION') {
      statusColor = AppColors.accentMint;
      statusText = "Inside";
    } else if (activityStatus == 'FIELD_MISSION') {
      statusColor = AppColors.accentAmber;
      statusText = "Outside";
    } else if (activityStatus == 'MEDICAL_EVAC') {
      statusColor = AppColors.accentRed;
      statusText = "Evac";
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.cardBorder)),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
              ),
            ),
            const SizedBox(height: 12),
            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(role, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withOpacity(0.3))),
              child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}