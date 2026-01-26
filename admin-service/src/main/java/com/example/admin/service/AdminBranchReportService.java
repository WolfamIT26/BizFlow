package com.example.admin.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.example.admin.dto.BranchGrowthPoint;
import com.example.admin.dto.BranchGrowthResponse;
import com.example.admin.dto.BranchRevenueSummary;
import com.example.admin.dto.BranchSummaryResponse;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class AdminBranchReportService {
    private static final DateTimeFormatter MONTH_LABEL = DateTimeFormatter.ofPattern("MM/yyyy");

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final String coreBaseUrl;

    public AdminBranchReportService(RestTemplate restTemplate,
                                    ObjectMapper objectMapper,
                                    @Value("${core.base-url:http://localhost:8080}") String coreBaseUrl) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
        this.coreBaseUrl = coreBaseUrl;
    }

    public BranchSummaryResponse buildBranchSummary(String authHeader) {
        List<Map<String, Object>> branches = fetchList(coreBaseUrl + "/api/dashboard/branches", authHeader);
        List<Map<String, Object>> users = fetchList(coreBaseUrl + "/api/users", authHeader);
        List<Map<String, Object>> orders = fetchList(coreBaseUrl + "/api/orders/summary", authHeader);

        Map<Long, Long> userBranchMap = mapUserToBranch(users);
        Map<Long, BigDecimal> revenueByBranch = new HashMap<>();
        Map<Long, Long> countByBranch = new HashMap<>();

        for (Map<String, Object> order : orders) {
            if (!isPaid(order)) {
                continue;
            }
            Long userId = toLong(order.get("userId"));
            if (userId == null) {
                continue;
            }
            Long branchId = userBranchMap.get(userId);
            if (branchId == null) {
                continue;
            }
            BigDecimal amount = toBigDecimal(order.get("totalAmount"));
            revenueByBranch.put(branchId, revenueByBranch.getOrDefault(branchId, BigDecimal.ZERO).add(amount));
            countByBranch.put(branchId, countByBranch.getOrDefault(branchId, 0L) + 1);
        }

        List<BranchRevenueSummary> summaries = new ArrayList<>();
        long activeBranches = 0;
        BigDecimal totalRevenue = BigDecimal.ZERO;

        for (Map<String, Object> branch : branches) {
            Long id = toLong(branch.get("id"));
            String name = toStringValue(branch.get("name"));
            String ownerName = toStringValue(branch.get("ownerName"));
            Boolean active = toBoolean(branch.get("active"));
            if (Boolean.TRUE.equals(active)) {
                activeBranches++;
            }
            BigDecimal revenue = id == null ? BigDecimal.ZERO : revenueByBranch.getOrDefault(id, BigDecimal.ZERO);
            long orderCount = id == null ? 0 : countByBranch.getOrDefault(id, 0L);
            totalRevenue = totalRevenue.add(revenue);
            summaries.add(new BranchRevenueSummary(id, name, ownerName, active, revenue, orderCount));
        }

        return new BranchSummaryResponse(branches.size(), activeBranches, totalRevenue, summaries);
    }

    public BranchGrowthResponse buildBranchGrowth(Long branchId, int months, String authHeader) {
        if (branchId == null) {
            return new BranchGrowthResponse(null, null, Collections.emptyList());
        }

        List<Map<String, Object>> branches = fetchList(coreBaseUrl + "/api/dashboard/branches", authHeader);
        List<Map<String, Object>> users = fetchList(coreBaseUrl + "/api/users", authHeader);
        List<Map<String, Object>> orders = fetchList(coreBaseUrl + "/api/orders/summary", authHeader);

        Map<Long, Long> userBranchMap = mapUserToBranch(users);
        Map<YearMonth, BigDecimal> revenueByMonth = new HashMap<>();
        Map<YearMonth, Long> countByMonth = new HashMap<>();

        for (Map<String, Object> order : orders) {
            if (!isPaid(order)) {
                continue;
            }
            Long userId = toLong(order.get("userId"));
            if (userId == null || !Objects.equals(userBranchMap.get(userId), branchId)) {
                continue;
            }
            LocalDateTime createdAt = toDateTime(order.get("createdAt"));
            if (createdAt == null) {
                continue;
            }
            YearMonth ym = YearMonth.from(createdAt);
            BigDecimal amount = toBigDecimal(order.get("totalAmount"));
            revenueByMonth.put(ym, revenueByMonth.getOrDefault(ym, BigDecimal.ZERO).add(amount));
            countByMonth.put(ym, countByMonth.getOrDefault(ym, 0L) + 1);
        }

        int size = months <= 0 ? 6 : Math.min(months, 24);
        YearMonth current = YearMonth.now();
        List<BranchGrowthPoint> points = new ArrayList<>();
        for (int i = size - 1; i >= 0; i--) {
            YearMonth ym = current.minusMonths(i);
            BigDecimal total = revenueByMonth.getOrDefault(ym, BigDecimal.ZERO);
            long count = countByMonth.getOrDefault(ym, 0L);
            points.add(new BranchGrowthPoint(ym.format(MONTH_LABEL), total, count));
        }

        String branchName = resolveBranchName(branches, branchId);
        return new BranchGrowthResponse(branchId, branchName, points);
    }

    private List<Map<String, Object>> fetchList(String url, String authHeader) {
        try {
            HttpHeaders headers = new HttpHeaders();
            if (authHeader != null && !authHeader.isBlank()) {
                headers.set(HttpHeaders.AUTHORIZATION, authHeader);
            }
            ResponseEntity<String> response = restTemplate.exchange(
                    url,
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

    private Map<Long, Long> mapUserToBranch(List<Map<String, Object>> users) {
        Map<Long, Long> result = new HashMap<>();
        for (Map<String, Object> user : users) {
            Long userId = toLong(user.get("id"));
            if (userId == null) {
                continue;
            }
            Object branchObj = user.get("branch");
            if (branchObj instanceof Map<?, ?> branchMap) {
                Long branchId = toLong(branchMap.get("id"));
                if (branchId != null) {
                    result.put(userId, branchId);
                }
            }
        }
        return result;
    }

    private boolean isPaid(Map<String, Object> order) {
        Object status = order.get("status");
        return status != null && "PAID".equalsIgnoreCase(String.valueOf(status));
    }

    private String resolveBranchName(List<Map<String, Object>> branches, Long branchId) {
        for (Map<String, Object> branch : branches) {
            if (Objects.equals(toLong(branch.get("id")), branchId)) {
                return toStringValue(branch.get("name"));
            }
        }
        return null;
    }

    private static String toStringValue(Object value) {
        return value == null ? null : String.valueOf(value);
    }

    private static Boolean toBoolean(Object value) {
        if (value instanceof Boolean bool) {
            return bool;
        }
        if (value == null) {
            return null;
        }
        return Boolean.parseBoolean(String.valueOf(value).toLowerCase(Locale.ROOT));
    }

    private static Long toLong(Object value) {
        if (value instanceof Number num) {
            return num.longValue();
        }
        if (value == null) {
            return null;
        }
        try {
            return Long.parseLong(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private static BigDecimal toBigDecimal(Object value) {
        if (value == null) {
            return BigDecimal.ZERO;
        }
        if (value instanceof BigDecimal bd) {
            return bd;
        }
        if (value instanceof Number num) {
            return BigDecimal.valueOf(num.doubleValue());
        }
        try {
            return new BigDecimal(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return BigDecimal.ZERO;
        }
    }

    private static LocalDateTime toDateTime(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof String str) {
            try {
                return java.time.OffsetDateTime.parse(str).toLocalDateTime();
            } catch (Exception ignored) {
            }
            try {
                return LocalDateTime.parse(str);
            } catch (Exception ignored) {
            }
        }
        return null;
    }
}
