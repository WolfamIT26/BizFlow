package com.example.useradmin.controller;

import com.example.useradmin.dto.AdminUserStatsResponse;
import com.example.useradmin.service.UserStatsService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserStatsController {
    private final UserStatsService userStatsService;

    public UserStatsController(UserStatsService userStatsService) {
        this.userStatsService = userStatsService;
    }

    @GetMapping("/api/admin/users/summary")
    public ResponseEntity<AdminUserStatsResponse> getSummary(@RequestParam(required = false, defaultValue = "all") String role,
                                                             @RequestParam(required = false) Integer days,
                                                             @RequestHeader(value = "Authorization", required = false) String authHeader,
                                                             HttpServletRequest request) {
        AdminUserStatsResponse response = userStatsService.buildStats(role, days);
        return ResponseEntity.ok(response);
    }
}
