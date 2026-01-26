package com.example.useradmin.controller;

import com.example.useradmin.dto.AdminSearchResponse;
import com.example.useradmin.service.UserSearchService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserSearchController {
    private final UserSearchService userSearchService;

    public UserSearchController(UserSearchService userSearchService) {
        this.userSearchService = userSearchService;
    }

    @GetMapping("/api/admin/search")
    public ResponseEntity<AdminSearchResponse> search(@RequestParam(required = false) String keyword,
                                                      @RequestParam(required = false, defaultValue = "all") String role,
                                                      @RequestParam(required = false, defaultValue = "8") int limit,
                                                      @RequestHeader(value = "Authorization", required = false) String authorization,
                                                      HttpServletRequest request) {
        AdminSearchResponse response = userSearchService.search(keyword, role, limit);
        return ResponseEntity.ok(response);
    }
}
