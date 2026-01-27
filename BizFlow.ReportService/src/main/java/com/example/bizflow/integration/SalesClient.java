package com.example.bizflow.integration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Service
public class SalesClient {

    private final RestTemplate restTemplate;
    private final String baseUrl;

    public SalesClient(RestTemplateBuilder builder,
                       @Value("${app.sales.base-url:http://localhost:8081}") String baseUrl) {
        this.restTemplate = builder.build();
        this.baseUrl = normalizeBaseUrl(baseUrl);
    }

    public List<OrderSnapshot> getOrders(LocalDate startDate, LocalDate endDate) {
        String from = startDate == null ? null : startDate.toString();
        String to = endDate == null ? null : endDate.toString();
        String url = baseUrl + "/api/orders/internal";
        if (from != null || to != null) {
            StringBuilder sb = new StringBuilder(url);
            sb.append("?");
            if (from != null) {
                sb.append("fromDate=").append(from);
            }
            if (to != null) {
                if (from != null) {
                    sb.append("&");
                }
                sb.append("toDate=").append(to);
            }
            url = sb.toString();
        }
        try {
            ResponseEntity<OrderSnapshot[]> response = restTemplate.getForEntity(url, OrderSnapshot[].class);
            OrderSnapshot[] body = response.getBody();
            return body == null ? Collections.emptyList() : Arrays.asList(body);
        } catch (Exception ex) {
            return Collections.emptyList();
        }
    }

    public List<PaymentSnapshot> getPayments(LocalDate startDate, LocalDate endDate) {
        if (startDate == null || endDate == null) {
            return Collections.emptyList();
        }
        String url = baseUrl + "/internal/payments?fromDate=" + startDate + "&toDate=" + endDate;
        try {
            ResponseEntity<PaymentSnapshot[]> response = restTemplate.getForEntity(url, PaymentSnapshot[].class);
            PaymentSnapshot[] body = response.getBody();
            return body == null ? Collections.emptyList() : Arrays.asList(body);
        } catch (Exception ex) {
            return Collections.emptyList();
        }
    }

    private String normalizeBaseUrl(String raw) {
        if (raw == null || raw.isBlank()) {
            return "http://localhost:8081";
        }
        return raw.endsWith("/") ? raw.substring(0, raw.length() - 1) : raw;
    }

    public static class OrderSnapshot {
        private Long id;
        private BigDecimal totalAmount;
        private java.time.LocalDateTime createdAt;
        private String status;
        private Boolean returnOrder;
        private String orderType;
        private String refundMethod;
        private List<OrderItemSnapshot> items;

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public BigDecimal getTotalAmount() {
            return totalAmount;
        }

        public void setTotalAmount(BigDecimal totalAmount) {
            this.totalAmount = totalAmount;
        }

        public java.time.LocalDateTime getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(java.time.LocalDateTime createdAt) {
            this.createdAt = createdAt;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public Boolean getReturnOrder() {
            return returnOrder;
        }

        public void setReturnOrder(Boolean returnOrder) {
            this.returnOrder = returnOrder;
        }

        public String getOrderType() {
            return orderType;
        }

        public void setOrderType(String orderType) {
            this.orderType = orderType;
        }

        public String getRefundMethod() {
            return refundMethod;
        }

        public void setRefundMethod(String refundMethod) {
            this.refundMethod = refundMethod;
        }

        public List<OrderItemSnapshot> getItems() {
            return items;
        }

        public void setItems(List<OrderItemSnapshot> items) {
            this.items = items;
        }
    }

    public static class OrderItemSnapshot {
        private Long productId;
        private Integer quantity;
        private BigDecimal price;
        private String productName;
        private String productCode;
        private Long categoryId;

        public Long getProductId() {
            return productId;
        }

        public void setProductId(Long productId) {
            this.productId = productId;
        }

        public Integer getQuantity() {
            return quantity;
        }

        public void setQuantity(Integer quantity) {
            this.quantity = quantity;
        }

        public BigDecimal getPrice() {
            return price;
        }

        public void setPrice(BigDecimal price) {
            this.price = price;
        }

        public String getProductName() {
            return productName;
        }

        public void setProductName(String productName) {
            this.productName = productName;
        }

        public String getProductCode() {
            return productCode;
        }

        public void setProductCode(String productCode) {
            this.productCode = productCode;
        }

        public Long getCategoryId() {
            return categoryId;
        }

        public void setCategoryId(Long categoryId) {
            this.categoryId = categoryId;
        }
    }

    public static class PaymentSnapshot {
        private Long id;
        private String method;
        private BigDecimal amount;
        private java.time.LocalDateTime paidAt;

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public String getMethod() {
            return method;
        }

        public void setMethod(String method) {
            this.method = method;
        }

        public BigDecimal getAmount() {
            return amount;
        }

        public void setAmount(BigDecimal amount) {
            this.amount = amount;
        }

        public java.time.LocalDateTime getPaidAt() {
            return paidAt;
        }

        public void setPaidAt(java.time.LocalDateTime paidAt) {
            this.paidAt = paidAt;
        }
    }
}
