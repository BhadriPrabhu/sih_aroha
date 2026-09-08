package com.nullhypothesis.aroha.controller;

import com.nullhypothesis.aroha.dto.ApiResponse;
import com.nullhypothesis.aroha.dto.InventoryItemDto;
import com.nullhypothesis.aroha.dto.StockDemandHistoryDto;
import com.nullhypothesis.aroha.dto.StockDto;
import com.nullhypothesis.aroha.dto.StockLogDto;
import com.nullhypothesis.aroha.service.CentralStockService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/remote/stocks")
public class CentralStockController {

    private final CentralStockService centralStockService;

    public CentralStockController(CentralStockService centralStockService) {
        this.centralStockService = centralStockService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<StockDto>>> getStocks(
            @RequestParam(required = false) String station_id,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String criticality_status) {
        List<StockDto> stocks = centralStockService.getAllStocks(station_id, category, criticality_status);
        return ResponseEntity.ok(ApiResponse.success(stocks, "Retrieved stock records"));
    }

    @GetMapping("/criticality")
    public ResponseEntity<ApiResponse<List<StockDto>>> getCriticalStocks(
            @RequestParam(required = false) String station_id,
            @RequestParam(defaultValue = "HIGH") String status) {
        List<StockDto> stocks = centralStockService.getAllStocks(station_id, null, status);
        return ResponseEntity.ok(ApiResponse.success(stocks, "Retrieved stocks filtered by criticality status: " + status));
    }

    @GetMapping("/sorted-criticality")
    public ResponseEntity<ApiResponse<List<StockDto>>> getStocksSortedByCriticality(
            @RequestParam(required = false) String station_id) {
        List<StockDto> stocks = centralStockService.getStocksSortedByCriticality(station_id);
        return ResponseEntity.ok(ApiResponse.success(stocks, "Retrieved stocks sorted from highest criticality score to lowest criticality score"));
    }

    @GetMapping({"/top-critical", "/top5-critical"})
    public ResponseEntity<ApiResponse<List<StockDto>>> getTop5CriticalStocks(
            @RequestParam(required = false) String station_id) {
        List<StockDto> stocks = centralStockService.getTop5CriticalStocks(station_id);
        return ResponseEntity.ok(ApiResponse.success(stocks, "Retrieved top 5 utmost criticality score stocks"));
    }

    @GetMapping("/logs")
    public ResponseEntity<ApiResponse<List<StockLogDto>>> getStockLogs(
            @RequestParam(required = false) String station_id,
            @RequestParam(required = false) String stock_id) {
        List<StockLogDto> logs = centralStockService.getStockLogs(station_id, stock_id);
        return ResponseEntity.ok(ApiResponse.success(logs, "Retrieved stock logs"));
    }

    @GetMapping("/inventory")
    public ResponseEntity<ApiResponse<List<InventoryItemDto>>> getInventoryItems(
            @RequestParam(required = false) String station_id,
            @RequestParam(required = false) String category) {
        List<InventoryItemDto> items = centralStockService.getInventoryItems(station_id, category);
        return ResponseEntity.ok(ApiResponse.success(items, "Retrieved inventory items"));
    }

    @GetMapping("/demand-history")
    public ResponseEntity<ApiResponse<List<StockDemandHistoryDto>>> getDemandHistory(
            @RequestParam(required = false) String station_id,
            @RequestParam(required = false) String stock_id) {
        List<StockDemandHistoryDto> history = centralStockService.getDemandHistory(station_id, stock_id);
        return ResponseEntity.ok(ApiResponse.success(history, "Retrieved stock demand history"));
    }
}
