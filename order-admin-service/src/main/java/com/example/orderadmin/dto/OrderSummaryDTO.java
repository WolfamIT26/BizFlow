package com.example.orderadmin.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class OrderSummaryDTO {
    private final Long id;
    private final Long userId;
    private final String userName;
    private final BigDecimal totalAmount;
    private final LocalDateTime createdAt;
    private final String status;

    public OrderSummaryDTO(Long id, Long userId, String userName, BigDecimal totalAmount, LocalDateTime createdAt, String status) {
        this.id = id;
        this.userId = userId;
        this.userName = userName;
        this.totalAmount = totalAmount;
        this.createdAt = createdAt;
        this.status = status;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public String getUserName() {
        return userName;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public String getStatus() {
        return status;
    }
}
