package com.nullhypothesis.aroha;

import com.nullhypothesis.aroha.dto.*;
import com.nullhypothesis.aroha.model.SyncAuditEntity;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class ArohaRemoteServerApplicationTests {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    private String getBaseUrl() {
        return "http://localhost:" + port + "/api/v1/remote";
    }

    @Test
    void contextLoads() {
        assertNotNull(restTemplate);
    }

    @Test
    void testGetStations() {
        ResponseEntity<ApiResponse<List<StationDto>>> response = restTemplate.exchange(
                getBaseUrl() + "/stations",
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<ApiResponse<List<StationDto>>>() {}
        );

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().isSuccess());
        assertNotNull(response.getBody().getData());
        assertFalse(response.getBody().getData().isEmpty());
    }

    @Test
    void testAdminCreateTeamAndAddMember() {
        // Admin Creates Team
        TeamDto newTeam = TeamDto.builder()
                .stationId("STATION-MAITRI")
                .teamId("TEAM-NCPOR-01")
                .teamName("Deep Ice Core Team")
                .activeStatus("ACTIVE")
                .build();

        HttpEntity<TeamDto> teamReq = new HttpEntity<>(newTeam);
        ResponseEntity<ApiResponse<TeamDto>> teamResp = restTemplate.exchange(
                getBaseUrl() + "/teams",
                HttpMethod.POST,
                teamReq,
                new ParameterizedTypeReference<ApiResponse<TeamDto>>() {}
        );

        assertEquals(HttpStatus.OK, teamResp.getStatusCode());
        assertNotNull(teamResp.getBody());
        assertTrue(teamResp.getBody().isSuccess());
        assertEquals("TEAM-NCPOR-01", teamResp.getBody().getData().getTeamId());

        // Admin Adds Member to Team
        MemberDto newMember = MemberDto.builder()
                .stationId("STATION-MAITRI")
                .memberId("MEM-NCPOR-01")
                .fullName("Dr. Alexis Vance")
                .role("Senior Geophysicist")
                .status("ACTIVE")
                .build();

        HttpEntity<MemberDto> memberReq = new HttpEntity<>(newMember);
        ResponseEntity<ApiResponse<MemberDto>> memberResp = restTemplate.exchange(
                getBaseUrl() + "/teams/TEAM-NCPOR-01/members",
                HttpMethod.POST,
                memberReq,
                new ParameterizedTypeReference<ApiResponse<MemberDto>>() {}
        );

        assertEquals(HttpStatus.OK, memberResp.getStatusCode());
        assertNotNull(memberResp.getBody());
        assertTrue(memberResp.getBody().isSuccess());
        assertEquals("TEAM-NCPOR-01", memberResp.getBody().getData().getTeamId());
        assertEquals("Dr. Alexis Vance", memberResp.getBody().getData().getFullName());
    }

    @Test
    void testProcessDeltaSyncAndQuery() {
        // Prepare Delta Sync Payload
        StockDto stockDto = StockDto.builder()
                .stockId("STK-REMOTE-001")
                .itemCode("MED-R01")
                .itemName("Antarctic Trauma Kit Remote")
                .category("MEDICAL")
                .subCategory("FIRST_AID")
                .unit("Kits")
                .totalQuantity(40)
                .minRequiredQuantity(10)
                .criticalityScore(4.8)
                .build();

        StockLogDto logDto = StockLogDto.builder()
                .logId("LOG-REMOTE-001")
                .stockId("STK-REMOTE-001")
                .operationType("ADDED")
                .changeQty(40)
                .reason("Initial Expedition Resupply")
                .loggedBy("Commander Harish")
                .build();

        TeamDto teamDto = TeamDto.builder()
                .teamId("TEAM-REMOTE-ALPHA")
                .teamName("Glacier Deep Core Team")
                .activeStatus("ACTIVE")
                .build();

        MemberDto memberDto = MemberDto.builder()
                .memberId("MEM-REMOTE-001")
                .teamId("TEAM-REMOTE-ALPHA")
                .fullName("Dr. Sarah Vance")
                .role("Lead Glaciologist")
                .status("ACTIVE")
                .build();

        SyncPayloadDto payload = SyncPayloadDto.builder()
                .stationId("STATION-MAITRI")
                .syncBatchId("BATCH-TEST-999")
                .stocks(Collections.singletonList(stockDto))
                .stockLogs(Collections.singletonList(logDto))
                .teams(Collections.singletonList(teamDto))
                .members(Collections.singletonList(memberDto))
                .build();

        HttpEntity<SyncPayloadDto> request = new HttpEntity<>(payload);
        ResponseEntity<ApiResponse<SyncAuditEntity>> syncResponse = restTemplate.exchange(
                getBaseUrl() + "/sync/delta",
                HttpMethod.POST,
                request,
                new ParameterizedTypeReference<ApiResponse<SyncAuditEntity>>() {}
        );

        assertEquals(HttpStatus.OK, syncResponse.getStatusCode());
        assertNotNull(syncResponse.getBody());
        assertTrue(syncResponse.getBody().isSuccess());
        assertEquals("SUCCESS", syncResponse.getBody().getData().getSyncStatus());
        assertEquals(4, syncResponse.getBody().getData().getRecordsCount());

        // Verify Synced Stock via Remote Stock API
        ResponseEntity<ApiResponse<List<StockDto>>> stocksResponse = restTemplate.exchange(
                getBaseUrl() + "/stocks?station_id=STATION-MAITRI&category=MEDICAL",
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<ApiResponse<List<StockDto>>>() {}
        );

        assertEquals(HttpStatus.OK, stocksResponse.getStatusCode());
        assertNotNull(stocksResponse.getBody());
        assertEquals(1, stocksResponse.getBody().getData().size());
        assertEquals("Antarctic Trauma Kit Remote", stocksResponse.getBody().getData().get(0).getItemName());
    }
}
