package com.example.admin.controller;

import com.example.admin.dto.AdminSearchResponse;
import com.example.admin.service.AdminSearchService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AdminSearchController {
    private final AdminSearchService adminSearchService;

    public AdminSearchController(AdminSearchService adminSearchService) {
        this.adminSearchService = adminSearchService;
    }

    @GetMapping("/api/admin/search")
    public ResponseEntity<AdminSearchResponse> search(@RequestParam(required = false) String keyword,
                                                      @RequestParam(required = false, defaultValue = "all") String role,
                                                      @RequestParam(required = false, defaultValue = "8") int limit,
                                                      HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        AdminSearchResponse response = adminSearchService.search(keyword, role, limit, authHeader);
        return ResponseEntity.ok(response);
    }
}
