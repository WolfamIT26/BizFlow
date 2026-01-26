package com.example.admin.service;

import com.example.admin.dto.AdminOrderDetail;
import com.example.admin.dto.AdminOrderItem;
import com.example.admin.dto.AdminOrderSummary;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
public class AdminOrderService {
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final String coreBaseUrl;
    private final AdminOrderEventPublisher eventPublisher;

    public AdminOrderService(RestTemplate restTemplate,
                             ObjectMapper objectMapper,
                             AdminOrderEventPublisher eventPublisher,
                             @Value("${core.base-url:http://localhost:8080}") String coreBaseUrl) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
        this.eventPublisher = eventPublisher;
        this.coreBaseUrl = coreBaseUrl;
    }

    public List<AdminOrderSummary> fetchOrderSummaries(Long branchId, String authHeader) {
        List<Map<String, Object>> orders = fetchList(coreBaseUrl + "/api/orders/summary", authHeader);
        if (orders.isEmpty()) {
            return Collections.emptyList();
        }

        List<Map<String, Object>> users = fetchList(coreBaseUrl + "/api/users", authHeader);
        Map<Long, BranchInfo> userBranchMap = mapUserToBranch(users);

        List<AdminOrderSummary> result = new ArrayList<>();
        for (Map<String, Object> order : orders) {
            Long userId = toLong(order.get("userId"));
            BranchInfo branch = userBranchMap.get(userId);
            if (branchId != null && (branch == null || !Objects.equals(branch.id, branchId))) {
                continue;
            }
            result.add(new AdminOrderSummary(
                    toLong(order.get("id")),
                    userId,
                    toStringValue(order.get("userName")),
                    toLong(order.get("customerId")),
                    toStringValue(order.get("customerName")),
                    toStringValue(order.get("customerPhone")),
                    toBigDecimal(order.get("totalAmount")),
                    toDateTime(order.get("createdAt")),
                    toInt(order.get("itemCount")),
                    toStringValue(order.get("invoiceNumber")),
                    toStringValue(order.get("status")),
                    toStringValue(order.get("note")),
                    branch == null ? null : branch.id,
                    branch == null ? null : branch.name
            ));
        }
        return result;
    }

    public AdminOrderDetail fetchOrderDetail(Long id, String authHeader, String viewer) {
        if (id == null) {
            return null;
        }
        Map<String, Object> order = fetchObject(coreBaseUrl + "/api/orders/" + id, authHeader);
        if (order == null || order.isEmpty()) {
            return null;
        }

        List<Map<String, Object>> users = fetchList(coreBaseUrl + "/api/users", authHeader);
        Map<Long, BranchInfo> userBranchMap = mapUserToBranch(users);
        Long userId = toLong(order.get("userId"));
        BranchInfo branch = userBranchMap.get(userId);

        List<AdminOrderItem> items = new ArrayList<>();
        Object rawItems = order.get("items");
        if (rawItems instanceof List<?> rawList) {
            for (Object itemObj : rawList) {
                if (!(itemObj instanceof Map<?, ?> itemMap)) {
                    continue;
                }
                Map<?, ?> item = itemMap;
                items.add(new AdminOrderItem(
                        toLong(item.get("id")),
                        toLong(item.get("productId")),
                        toStringValue(item.get("productName")),
                        toInt(item.get("quantity")),
                        toBigDecimal(item.get("price")),
                        toBigDecimal(item.get("lineTotal")),
                        toStringValue(item.get("productCode")),
                        toStringValue(item.get("barcode")),
                        toStringValue(item.get("unit"))
                ));
            }
        }

        AdminOrderDetail detail = new AdminOrderDetail(
                toLong(order.get("id")),
                userId,
                toStringValue(order.get("userName")),
                toLong(order.get("customerId")),
                toStringValue(order.get("customerName")),
                toStringValue(order.get("customerPhone")),
                toBigDecimal(order.get("totalAmount")),
                toDateTime(order.get("createdAt")),
                toStringValue(order.get("invoiceNumber")),
                toStringValue(order.get("status")),
                toStringValue(order.get("note")),
                items,
                branch == null ? null : branch.id,
                branch == null ? null : branch.name
        );

        eventPublisher.publishOrderViewed(detail, viewer);
        return detail;
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

    private Map<String, Object> fetchObject(String url, String authHeader) {
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
                return null;
            }
            return objectMapper.readValue(response.getBody(), new TypeReference<Map<String, Object>>() {});
        } catch (Exception ex) {
            return null;
        }
    }

    private Map<Long, BranchInfo> mapUserToBranch(List<Map<String, Object>> users) {
        Map<Long, BranchInfo> result = new HashMap<>();
        for (Map<String, Object> user : users) {
            Long userId = toLong(user.get("id"));
            if (userId == null) {
                continue;
            }
            Object branchObj = user.get("branch");
            if (branchObj instanceof Map<?, ?> branchMap) {
                Long branchId = toLong(branchMap.get("id"));
                String branchName = toStringValue(branchMap.get("name"));
                if (branchId != null) {
                    result.put(userId, new BranchInfo(branchId, branchName));
                }
            }
        }
        return result;
    }

    private static class BranchInfo {
        private final Long id;
        private final String name;

        private BranchInfo(Long id, String name) {
            this.id = id;
            this.name = name;
        }
    }

    private static String toStringValue(Object value) {
        return value == null ? null : String.valueOf(value);
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

    private static BigDecimal toBigDecimal(Object value) {
        if (value == null) return BigDecimal.ZERO;
        if (value instanceof BigDecimal bd) return bd;
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
