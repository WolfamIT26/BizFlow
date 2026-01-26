package com.example.admin.controller;

import com.example.admin.dto.AdminUserStatsResponse;
import com.example.admin.service.AdminUserStatsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;

@RestController
public class AdminUserStatsController {
    private final AdminUserStatsService statsService;

    public AdminUserStatsController(AdminUserStatsService statsService) {
        this.statsService = statsService;
    }

    @GetMapping("/api/admin/users/summary")
    public ResponseEntity<AdminUserStatsResponse> getUserSummary(
            @RequestParam(required = false, defaultValue = "all") String role,
            @RequestParam(required = false) Integer days,
            HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        AdminUserStatsResponse response = statsService.buildStats(role, days, authHeader);
        return ResponseEntity.ok(response);
    }
}
