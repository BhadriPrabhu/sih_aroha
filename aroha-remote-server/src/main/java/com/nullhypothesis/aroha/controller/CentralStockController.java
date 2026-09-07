package com.nullhypothesis.aroha.controller;

import com.nullhypothesis.aroha.dto.ApiResponse;
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
            @RequestParam(required = false) String category) {
        List<StockDto> stocks = centralStockService.getAllStocks(station_id, category);
        return ResponseEntity.ok(ApiResponse.success(stocks, "Retrieved stock records"));
    }

    @GetMapping("/logs")
    public ResponseEntity<ApiResponse<List<StockLogDto>>> getStockLogs(
            @RequestParam(required = false) String station_id,
            @RequestParam(required = false) String stock_id) {
        List<StockLogDto> logs = centralStockService.getStockLogs(station_id, stock_id);
        return ResponseEntity.ok(ApiResponse.success(logs, "Retrieved stock logs"));
    }
}
