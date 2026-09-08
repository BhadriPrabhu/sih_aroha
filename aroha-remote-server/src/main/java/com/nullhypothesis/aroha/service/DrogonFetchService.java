package com.nullhypothesis.aroha.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nullhypothesis.aroha.model.*;
import com.nullhypothesis.aroha.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class DrogonFetchService {

    private static final Logger log = LoggerFactory.getLogger(DrogonFetchService.class);

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final StationRepository stationRepository;
    private final StockMasterRepository stockMasterRepository;
    private final StockLogRepository stockLogRepository;
    private final TeamRepository teamRepository;
    private final MemberRepository memberRepository;
    private final InventoryItemRepository inventoryItemRepository;
    private final SyncAuditRepository syncAuditRepository;

    @Value("${drogon.server.base-url:http://localhost:8080}")
    private String drogonBaseUrl;

    public DrogonFetchService(RestTemplate restTemplate,
                              ObjectMapper objectMapper,
                              StationRepository stationRepository,
                              StockMasterRepository stockMasterRepository,
                              StockLogRepository stockLogRepository,
                              TeamRepository teamRepository,
                              MemberRepository memberRepository,
                              InventoryItemRepository inventoryItemRepository,
                              SyncAuditRepository syncAuditRepository) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
        this.stationRepository = stationRepository;
        this.stockMasterRepository = stockMasterRepository;
        this.stockLogRepository = stockLogRepository;
        this.teamRepository = teamRepository;
        this.memberRepository = memberRepository;
        this.inventoryItemRepository = inventoryItemRepository;
        this.syncAuditRepository = syncAuditRepository;
    }

    @Transactional
    public SyncAuditEntity fetchAllFromDrogon(String stationId) {
        String targetStationId = (stationId != null && !stationId.isEmpty()) ? stationId : "STATION-MAITRI";
        String batchId = "FETCH-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        int totalFetched = 0;

        // 1. Ensure Station Record Exists
        StationEntity station = stationRepository.findByStationId(targetStationId)
                .orElseGet(() -> StationEntity.builder()
                        .stationId(targetStationId)
                        .stationName("Base Station (" + targetStationId + ")")
                        .location("Antarctica")
                        .status("ACTIVE")
                        .build());
        station.setLastSyncAt(LocalDateTime.now());
        stationRepository.save(station);

        // 2. Fetch Stocks from Drogon Server
        try {
            String stocksUrl = drogonBaseUrl + "/api/v1/facility/stocks";
            log.info("Fetching stocks from Drogon URL: {}", stocksUrl);
            ResponseEntity<String> response = restTemplate.getForEntity(stocksUrl, String.class);
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode rootNode = objectMapper.readTree(response.getBody());
                JsonNode stocksNode = rootNode.isArray() ? rootNode : rootNode.get("stocks");
                if (stocksNode != null && stocksNode.isArray()) {
                    for (JsonNode stockNode : stocksNode) {
                        String stockId = stockNode.has("id") ? stockNode.get("id").asText() :
                                        (stockNode.has("stock_id") ? stockNode.get("stock_id").asText() : UUID.randomUUID().toString());
                        String name = stockNode.has("name") ? stockNode.get("name").asText() :
                                     (stockNode.has("item_name") ? stockNode.get("item_name").asText() : "Unnamed Stock");
                        String category = stockNode.has("category") ? stockNode.get("category").asText() : "GENERAL";
                        
                        StockMasterEntity entity = stockMasterRepository.findByStationIdAndStockId(targetStationId, stockId)
                                .orElseGet(() -> StockMasterEntity.builder()
                                        .stationId(targetStationId)
                                        .stockId(stockId)
                                        .build());

                        entity.setItemCode(stockNode.has("item_code") ? stockNode.get("item_code").asText() : stockId);
                        entity.setItemName(name);
                        entity.setCategory(category);
                        entity.setStockAvailable(stockNode.has("stock_available") ? stockNode.get("stock_available").asDouble() : 0.0);
                        entity.setStockConsumed(stockNode.has("stock_consumed") ? stockNode.get("stock_consumed").asDouble() : 0.0);
                        entity.setPresentStock(stockNode.has("present_stock") ? stockNode.get("present_stock").asDouble() : 0.0);
                        entity.setCriticalityRate(stockNode.has("criticality_rate") ? stockNode.get("criticality_rate").asDouble() : 0.5);
                        entity.setCriticalityScore(stockNode.has("criticality_score") ? stockNode.get("criticality_score").asDouble() : 0.0);
                        entity.setEssentialityScore(stockNode.has("essentiality_score") ? stockNode.get("essentiality_score").asDouble() : 0.5);
                        entity.setLeadTimeDays(stockNode.has("lead_time_days") ? stockNode.get("lead_time_days").asDouble() : 30.0);
                        if (stockNode.has("criticality_status")) {
                            entity.setCriticalityStatus(stockNode.get("criticality_status").asText());
                        }
                        entity.setUpdatedAt(LocalDateTime.now());

                        stockMasterRepository.save(entity);
                        totalFetched++;
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Could not fetch stocks from Drogon server at {}: {}", drogonBaseUrl, e.getMessage());
        }

        // 3. Fetch Teams from Drogon Server
        try {
            String teamsUrl = drogonBaseUrl + "/api/v1/facility/teams";
            log.info("Fetching teams from Drogon URL: {}", teamsUrl);
            ResponseEntity<String> response = restTemplate.getForEntity(teamsUrl, String.class);
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode rootNode = objectMapper.readTree(response.getBody());
                JsonNode teamsNode = rootNode.isArray() ? rootNode : rootNode.get("teams");
                if (teamsNode != null && teamsNode.isArray()) {
                    for (JsonNode teamNode : teamsNode) {
                        String teamId = teamNode.has("teamid") ? teamNode.get("teamid").asText() :
                                       (teamNode.has("team_id") ? teamNode.get("team_id").asText() : UUID.randomUUID().toString());
                        String teamName = teamNode.has("teamname") ? teamNode.get("teamname").asText() :
                                         (teamNode.has("team_name") ? teamNode.get("team_name").asText() : "Unnamed Team");
                        String status = teamNode.has("active_status") ? teamNode.get("active_status").asText() : "ACTIVE";

                        TeamEntity entity = teamRepository.findByStationIdAndTeamId(targetStationId, teamId)
                                .orElseGet(() -> TeamEntity.builder()
                                        .stationId(targetStationId)
                                        .teamId(teamId)
                                        .build());

                        entity.setTeamName(teamName);
                        entity.setActiveStatus(status);
                        entity.setCreatedAt(LocalDateTime.now());

                        teamRepository.save(entity);
                        totalFetched++;
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Could not fetch teams from Drogon server at {}: {}", drogonBaseUrl, e.getMessage());
        }

        // 4. Fetch Team Members from Drogon Server
        try {
            String membersUrl = drogonBaseUrl + "/api/v1/facility/members";
            log.info("Fetching members from Drogon URL: {}", membersUrl);
            ResponseEntity<String> response = restTemplate.getForEntity(membersUrl, String.class);
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode rootNode = objectMapper.readTree(response.getBody());
                JsonNode membersNode = rootNode.isArray() ? rootNode : rootNode.get("members");
                if (membersNode != null && membersNode.isArray()) {
                    for (JsonNode memberNode : membersNode) {
                        String memberId = memberNode.has("id") ? memberNode.get("id").asText() :
                                         (memberNode.has("member_id") ? memberNode.get("member_id").asText() : UUID.randomUUID().toString());
                        String teamId = memberNode.has("teamid") ? memberNode.get("teamid").asText() : "UNASSIGNED";
                        String name = memberNode.has("name") ? memberNode.get("name").asText() :
                                     (memberNode.has("full_name") ? memberNode.get("full_name").asText() : "Anonymous");
                        String role = memberNode.has("role") ? memberNode.get("role").asText() : "MEMBER";
                        String status = memberNode.has("activity_status") ? memberNode.get("activity_status").asText() : "ACTIVE";

                        MemberEntity entity = memberRepository.findByStationIdAndMemberId(targetStationId, memberId)
                                .orElseGet(() -> MemberEntity.builder()
                                        .stationId(targetStationId)
                                        .memberId(memberId)
                                        .build());

                        entity.setTeamId(teamId);
                        entity.setFullName(name);
                        entity.setRole(role);
                        entity.setStatus(status);
                        entity.setUpdatedAt(LocalDateTime.now());

                        memberRepository.save(entity);
                        totalFetched++;
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Could not fetch team members from Drogon server at {}: {}", drogonBaseUrl, e.getMessage());
        }

        // 5. Save Sync Audit Log
        SyncAuditEntity audit = SyncAuditEntity.builder()
                .stationId(targetStationId)
                .syncBatchId(batchId)
                .payloadType("FETCH_FROM_DROGON")
                .recordsCount(totalFetched)
                .syncStatus("SUCCESS")
                .syncedAt(LocalDateTime.now())
                .build();

        return syncAuditRepository.save(audit);
    }
}
