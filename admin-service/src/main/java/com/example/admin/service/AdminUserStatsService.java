package com.example.admin.service;

import com.example.admin.dto.AdminUserStatsResponse;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@Service
public class AdminUserStatsService {
    private static final int DEFAULT_WINDOW_DAYS = 30;

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final String coreBaseUrl;

    public AdminUserStatsService(RestTemplate restTemplate,
                                 ObjectMapper objectMapper,
                                 @Value("${core.base-url:http://localhost:8080}") String coreBaseUrl) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
        this.coreBaseUrl = coreBaseUrl;
    }

    public AdminUserStatsResponse buildStats(String role, Integer windowDays, String authHeader) {
        List<Map<String, Object>> users = fetchUsers(authHeader);
        if (users.isEmpty()) {
            return new AdminUserStatsResponse(0, 0, resolveWindowDays(windowDays));
        }

        int days = resolveWindowDays(windowDays);
        LocalDateTime threshold = LocalDateTime.now().minusDays(days);
        int activeUsers = 0;
        int newRegistrations = 0;

        for (Map<String, Object> user : users) {
            String roleValue = extractRole(user.get("role"));
            if (role != null && !role.isBlank() && !role.equalsIgnoreCase("all") && !roleValue.equalsIgnoreCase(role)) {
                continue;
            }

            Boolean enabled = toBoolean(user.get("enabled"));
            if (Boolean.TRUE.equals(enabled)) {
                activeUsers++;
            }

            LocalDateTime createdAt = parseDateTime(user.get("createdAt"));
            if (createdAt != null && !createdAt.isBefore(threshold)) {
                newRegistrations++;
            }
        }

        return new AdminUserStatsResponse(activeUsers, newRegistrations, days);
    }

    private List<Map<String, Object>> fetchUsers(String authHeader) {
        try {
            HttpHeaders headers = new HttpHeaders();
            if (authHeader != null && !authHeader.isBlank()) {
                headers.set(HttpHeaders.AUTHORIZATION, authHeader);
            }
            ResponseEntity<String> response = restTemplate.exchange(
                    coreBaseUrl + "/api/users",
                    HttpMethod.GET,
                    new HttpEntity<>(headers),
                    String.class
            );
            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                return Collections.emptyList();
            }
            return objectMapper.readValue(response.getBody(), new TypeReference<List<Map<String, Object>>>() {});
        } catch (Exception ex) {
            return Collections.emptyList();
        }
    }

    private int resolveWindowDays(Integer windowDays) {
        if (windowDays == null || windowDays <= 0) {
            return DEFAULT_WINDOW_DAYS;
        }
        return windowDays;
    }

    private static LocalDateTime parseDateTime(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number num) {
            long epochMillis = num.longValue();
            return LocalDateTime.ofInstant(Instant.ofEpochMilli(epochMillis), ZoneId.systemDefault());
        }
        if (value instanceof String text) {
            String trimmed = text.trim();
            if (trimmed.isEmpty()) {
                return null;
            }
            try {
                return LocalDateTime.parse(trimmed);
            } catch (DateTimeParseException ex) {
                try {
                    return OffsetDateTime.parse(trimmed).toLocalDateTime();
                } catch (DateTimeParseException ignored) {
                    return null;
                }
            }
        }
        return null;
    }

    private static String extractRole(Object roleObj) {
        if (roleObj == null) {
            return "";
        }
        if (roleObj instanceof String) {
            return (String) roleObj;
        }
        if (roleObj instanceof Map<?, ?> map) {
            Object name = map.get("name");
            if (name == null) {
                name = map.get("code");
            }
            return name == null ? "" : String.valueOf(name);
        }
        return String.valueOf(roleObj);
    }

    private static Boolean toBoolean(Object value) {
        if (value == null) return null;
        if (value instanceof Boolean bool) {
            return bool;
        }
        return Boolean.parseBoolean(String.valueOf(value));
    }
}
