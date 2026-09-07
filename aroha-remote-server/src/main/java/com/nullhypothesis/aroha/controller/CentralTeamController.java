package com.nullhypothesis.aroha.controller;

import com.nullhypothesis.aroha.dto.ApiResponse;
import com.nullhypothesis.aroha.dto.MemberDto;
import com.nullhypothesis.aroha.dto.TeamDto;
import com.nullhypothesis.aroha.service.CentralTeamService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/remote/teams")
public class CentralTeamController {

    private final CentralTeamService centralTeamService;

    public CentralTeamController(CentralTeamService centralTeamService) {
        this.centralTeamService = centralTeamService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<TeamDto>>> getTeams(
            @RequestParam(required = false) String station_id) {
        List<TeamDto> teams = centralTeamService.getTeams(station_id);
        return ResponseEntity.ok(ApiResponse.success(teams, "Retrieved team records"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<TeamDto>> createTeam(@Valid @RequestBody TeamDto teamDto) {
        TeamDto created = centralTeamService.createTeam(teamDto);
        return ResponseEntity.ok(ApiResponse.success(created, "Team created successfully by central remote admin"));
    }

    @GetMapping("/members")
    public ResponseEntity<ApiResponse<List<MemberDto>>> getMembers(
            @RequestParam(required = false) String station_id,
            @RequestParam(required = false) String team_id) {
        List<MemberDto> members = centralTeamService.getMembers(station_id, team_id);
        return ResponseEntity.ok(ApiResponse.success(members, "Retrieved team member records"));
    }

    @PostMapping("/members")
    public ResponseEntity<ApiResponse<MemberDto>> addMember(@Valid @RequestBody MemberDto memberDto) {
        MemberDto added = centralTeamService.addMember(memberDto);
        return ResponseEntity.ok(ApiResponse.success(added, "Member added successfully by central remote admin"));
    }

    @PostMapping("/{teamId}/members")
    public ResponseEntity<ApiResponse<MemberDto>> addMemberToTeam(
            @PathVariable String teamId,
            @Valid @RequestBody MemberDto memberDto) {
        memberDto.setTeamId(teamId);
        MemberDto added = centralTeamService.addMember(memberDto);
        return ResponseEntity.ok(ApiResponse.success(added, "Member added to team " + teamId + " successfully by central remote admin"));
    }
}
