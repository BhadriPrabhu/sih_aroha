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

      final responses = await Future.wait([
        dio.get(ApiConstants.getTeams),
        dio.get(ApiConstants.getMembers),
      ]);

      if (mounted) {
        setState(() {
          _teams = [
            {'teamid': 'ALL', 'teamname': 'All Members'},
          ];
          if (responses[0].statusCode == 200)
            _teams.addAll(responses[0].data['teams'] ?? []);
          if (responses[1].statusCode == 200)
            _members = responses[1].data['members'] ?? [];

          _isLoadingTeams = false;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _teams = [
            {'teamid': 'ALL', 'teamname': 'All Members'},
            {'teamid': 'T1', 'teamname': 'Alpha Team'},
          ];

          _members = [
            {
              'id': 'm1',
              'name': 'Sarah Connor',
              'role': 'Lead Geologist',
              'activity_status': 'ON_STATION',
            },
            {
              'id': 'm2',
              'name': 'Marcus Wright',
              'role': 'Field Medic',
              'activity_status': 'FIELD_MISSION',
            },
          ];

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
      final url =
          teamId == 'ALL'
              ? ApiConstants.getMembers
              : ApiConstants.getTeamMembers(teamId);
      final response = await dio.get(url);

      if (response.statusCode == 200)
        setState(() => _members = response.data['members'] ?? []);
    } catch (e) {
      print("Error fetching members: $e");
    } finally {
      if (mounted){
        setState(() {
          _isLoadingMembers = false;
          _selectedTeamId = teamId;
        });
      }
    }
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
        Theme.of(context).cardTheme.color ?? AppColors.surfaceObsidian;
    final borderColor =
        Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                "Personnel Movement",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: primaryText,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // 1. Group Selector (High Contrast & Large Touch Targets)
            SizedBox(
              height: 100,
              child:
                  _isLoadingTeams
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.polarCyan,
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: _teams.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final team = _teams[index];
                          final isSelected = _selectedTeamId == team['teamid'];
                          final String displayName =
                              team['teamname'] ?? 'Unknown';
                          final String avatarLetter =
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : '?';

                          return GestureDetector(
                            onTap: () => _fetchMembersForTeam(team['teamid']),
                            behavior:
                                HitTestBehavior
                                    .opaque, // Expands hit area for gloves
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height:
                                      64, // Human Factors: Minimum 64px for avatars
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? (isLight
                                                  ? Colors.black
                                                  : AppColors.polarCyan)
                                              : borderColor,
                                      width:
                                          isSelected
                                              ? (isLight ? 4 : 3)
                                              : (isLight ? 2 : 1),
                                    ),
                                    color:
                                        isLight && !isSelected
                                            ? Colors.white
                                            : surfaceColor,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    avatarLetter,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          isSelected
                                              ? (isLight
                                                  ? Colors.black
                                                  : AppColors.polarCyan)
                                              : secondaryText,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  displayName.length > 10
                                      ? '${displayName.substring(0, 8)}...'
                                      : displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                    color:
                                        isSelected
                                            ? primaryText
                                            : secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(
                "ACTIVE ROSTER",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: secondaryText,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // 2. Member Grid Layer
            Expanded(
              child:
                  _isLoadingMembers
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.polarCyan,
                        ),
                      )
                      : _members.isEmpty
                      ? Center(
                        child: Text(
                          "No personnel found",
                          style: TextStyle(color: secondaryText),
                        ),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 120,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          return _buildMemberTile(
                            memberData: _members[index],
                            isLight: isLight,
                            pText: primaryText,
                            sText: secondaryText,
                            surface: surfaceColor,
                            border: borderColor,
                            onTap:
                                () => context.push(
                                  '/movement/profile',
                                  extra: _members[index],
                                ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile({
    required Map<String, dynamic> memberData,
    required bool isLight,
    required Color pText,
    required Color sText,
    required Color surface,
    required Color border,
    required VoidCallback onTap,
  }) {
    final String name = memberData['name'] ?? 'Unknown';
    final String role = memberData['role'] ?? 'No Role';
    final String activityStatus = memberData['activity_status'] ?? 'UNKNOWN';

    Color statusColor = AppColors.textMeta;
    String statusText = activityStatus.replaceAll('_', ' ');

    if (activityStatus == 'ON_STATION') {
      statusColor = AppColors.statusNominal;
      statusText = "ON BASE";
    } else if (activityStatus == 'FIELD_MISSION') {
      statusColor = AppColors.statusWarning;
      statusText = "IN FIELD";
    } else if (activityStatus == 'MEDICAL_EVAC') {
      statusColor = AppColors.statusCritical;
      statusText = "EVAC";
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: isLight ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isLight ? Colors.white : AppColors.canvasBlack,
                shape: BoxShape.circle,
                border: Border.all(color: border, width: isLight ? 2 : 1),
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: pText,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: pText,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: sText,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: statusColor.withOpacity(isLight ? 1.0 : 0.5),
                  width: 1.5,
                ),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
