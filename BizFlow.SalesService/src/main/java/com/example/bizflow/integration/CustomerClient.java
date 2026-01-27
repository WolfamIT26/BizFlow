package com.example.bizflow.integration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.example.bizflow.entity.CustomerTier;
import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@Service
public class CustomerClient {

    private final RestTemplate restTemplate;
    private final String baseUrl;

    public CustomerClient(RestTemplateBuilder builder,
                          @Value("${app.customer.base-url:http://localhost:8085}") String baseUrl) {
        this.restTemplate = builder.build();
        this.baseUrl = normalizeBaseUrl(baseUrl);
    }

    public CustomerSnapshot getCustomer(Long id) {
        if (id == null) {
            return null;
        }
        try {
            ResponseEntity<CustomerSnapshot> response = restTemplate.getForEntity(
                    baseUrl + "/api/customers/" + id,
                    CustomerSnapshot.class
            );
            return response.getBody();
        } catch (Exception ex) {
            return null;
        }
    }

    public void addPoints(Long customerId, BigDecimal totalAmount, String reference) {
        if (customerId == null || totalAmount == null) {
            return;
        }
        try {
            Map<String, Object> payload = Map.of(
                    "customerId", customerId,
                    "totalAmount", totalAmount,
                    "reference", reference
            );
            restTemplate.postForEntity(baseUrl + "/internal/customers/points/add", payload, Void.class);
        } catch (Exception ignored) {
        }
    }

    public int redeemPoints(Long customerId, int points) {
        if (customerId == null || points <= 0) {
            return 0;
        }
        try {
            Map<String, Object> payload = Map.of(
                    "customerId", customerId,
                    "points", points
            );
            ResponseEntity<Map> response = restTemplate.postForEntity(
                    baseUrl + "/internal/customers/points/redeem",
                    payload,
                    Map.class
            );
            Object redeemed = response.getBody() == null ? null : response.getBody().get("redeemed");
            if (redeemed instanceof Number) {
                return ((Number) redeemed).intValue();
            }
        } catch (Exception ignored) {
        }
        return 0;
    }

    public List<Long> searchCustomerIds(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return Collections.emptyList();
        }
        try {
            ResponseEntity<Long[]> response = restTemplate.getForEntity(
                    baseUrl + "/internal/customers/search?keyword=" + java.net.URLEncoder.encode(keyword, java.nio.charset.StandardCharsets.UTF_8),
                    Long[].class
            );
            Long[] body = response.getBody();
            return body == null ? Collections.emptyList() : java.util.Arrays.asList(body);
        } catch (Exception ex) {
            return Collections.emptyList();
        }
    }

    private String normalizeBaseUrl(String raw) {
        if (raw == null || raw.isBlank()) {
            return "http://localhost:8085";
        }
        return raw.endsWith("/") ? raw.substring(0, raw.length() - 1) : raw;
    }

    public static class CustomerSnapshot {
        private Long id;
        private String name;
        private String phone;
        private Integer totalPoints;
        private Integer monthlyPoints;
        private CustomerTier tier;

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getPhone() {
            return phone;
        }

        public void setPhone(String phone) {
            this.phone = phone;
        }

        public Integer getTotalPoints() {
            return totalPoints;
        }

        public void setTotalPoints(Integer totalPoints) {
            this.totalPoints = totalPoints;
        }

        public Integer getMonthlyPoints() {
            return monthlyPoints;
        }

        public void setMonthlyPoints(Integer monthlyPoints) {
            this.monthlyPoints = monthlyPoints;
        }

        public CustomerTier getTier() {
            return tier;
        }

        public void setTier(CustomerTier tier) {
            this.tier = tier;
        }
    }
}
