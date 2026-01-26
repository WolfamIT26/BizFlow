package com.example.admin.service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.example.admin.dto.AdminCustomerSummary;
import com.example.admin.dto.AdminSearchResponse;
import com.example.admin.dto.AdminUserSummary;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class AdminSearchService {
    private static final Pattern DIACRITICS = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final String coreBaseUrl;

    public AdminSearchService(RestTemplate restTemplate,
                              ObjectMapper objectMapper,
                              @Value("${core.base-url:http://localhost:8080}") String coreBaseUrl) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
        this.coreBaseUrl = coreBaseUrl;
    }

    public AdminSearchResponse search(String keyword, String role, int limit, String authHeader) {
        String trimmed = keyword == null ? "" : keyword.trim();
        if (trimmed.isEmpty()) {
            return new AdminSearchResponse(Collections.emptyList(), Collections.emptyList(), 0, 0);
        }

        List<AdminUserSummary> users = filterUsers(trimmed, role, limit, authHeader);
        List<AdminCustomerSummary> customers = filterCustomers(trimmed, limit, authHeader);

        return new AdminSearchResponse(users, customers, users.size(), customers.size());
    }

    private List<AdminUserSummary> filterUsers(String keyword, String role, int limit, String authHeader) {
        List<Map<String, Object>> raw = fetchList(coreBaseUrl + "/api/users", authHeader);
        if (raw.isEmpty()) {
            return Collections.emptyList();
        }

        String normalizedKeyword = normalize(keyword);
        List<AdminUserSummary> results = new ArrayList<>();
        for (Map<String, Object> user : raw) {
            String roleValue = extractRole(user.get("role"));
            if (role != null && !role.equalsIgnoreCase("all") && !roleValue.equalsIgnoreCase(role)) {
                continue;
            }
            String combined = normalize(String.valueOf(user.get("fullName")) + " "
                    + String.valueOf(user.get("username")) + " "
                    + String.valueOf(user.get("email")) + " "
                    + String.valueOf(user.get("phoneNumber")) + " "
                    + String.valueOf(user.get("id")));
            if (!combined.contains(normalizedKeyword)) {
                continue;
            }
            AdminUserSummary summary = new AdminUserSummary(
                    toLong(user.get("id")),
                    toStringValue(user.get("username")),
                    toStringValue(user.get("fullName")),
                    toStringValue(user.get("email")),
                    toStringValue(user.get("phoneNumber")),
                    roleValue,
                    toBoolean(user.get("enabled"))
            );
            results.add(summary);
            if (results.size() >= limit) {
                break;
            }
        }
        return results;
    }

    private List<AdminCustomerSummary> filterCustomers(String keyword, int limit, String authHeader) {
        List<Map<String, Object>> raw = fetchList(coreBaseUrl + "/api/customers", authHeader);
        if (raw.isEmpty()) {
            return Collections.emptyList();
        }
        String normalizedKeyword = normalize(keyword);
        List<AdminCustomerSummary> results = new ArrayList<>();
        for (Map<String, Object> customer : raw) {
            String combined = normalize(String.valueOf(customer.get("name")) + " "
                    + String.valueOf(customer.get("phone")) + " "
                    + String.valueOf(customer.get("email")) + " "
                    + String.valueOf(customer.get("id")));
            if (!combined.contains(normalizedKeyword)) {
                continue;
            }
            AdminCustomerSummary summary = new AdminCustomerSummary(
                    toLong(customer.get("id")),
                    toStringValue(customer.get("name")),
                    toStringValue(customer.get("phone")),
                    toStringValue(customer.get("email")),
                    toInt(customer.get("totalPoints")),
                    toStringValue(customer.get("tier"))
            );
            results.add(summary);
            if (results.size() >= limit) {
                break;
            }
        }
        return results;
    }

    private List<Map<String, Object>> fetchList(String url, String authHeader) {
        try {
            HttpHeaders headers = new HttpHeaders();
            if (authHeader != null && !authHeader.isBlank()) {
                headers.set(HttpHeaders.AUTHORIZATION, authHeader);
            }
            @SuppressWarnings("null")
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(headers), String.class);
            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                return Collections.emptyList();
            }
            return objectMapper.readValue(response.getBody(), new TypeReference<List<Map<String, Object>>>() {});
        } catch (Exception ex) {
            return Collections.emptyList();
        }
    }

    private static String normalize(String value) {
        if (value == null) {
            return "";
        }
        String lower = value.toLowerCase(Locale.ROOT);
        String normalized = Normalizer.normalize(lower, Normalizer.Form.NFD);
        return DIACRITICS.matcher(normalized).replaceAll("");
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

    private static String toStringValue(Object value) {
        return value == null ? null : String.valueOf(value);
    }

    private static Long toLong(Object value) {
        if (value == null) return null;
        if (value instanceof Number num) {
            return num.longValue();
        }
        try {
            return Long.parseLong(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private static Integer toInt(Object value) {
        if (value == null) return null;
        if (value instanceof Number num) {
            return num.intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private static Boolean toBoolean(Object value) {
        if (value == null) return null;
        if (value instanceof Boolean bool) {
            return bool;
        }
        return Boolean.parseBoolean(String.valueOf(value));
    }
}
