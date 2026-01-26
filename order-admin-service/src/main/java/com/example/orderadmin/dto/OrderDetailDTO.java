package com.example.orderadmin.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class OrderDetailDTO {
    private final Long id;
    private final Long userId;
    private final String userName;
    private final BigDecimal totalAmount;
    private final LocalDateTime createdAt;
    private final String status;
    private final List<OrderItemDTO> items;

    public OrderDetailDTO(Long id,
                          Long userId,
                          String userName,
                          BigDecimal totalAmount,
                          LocalDateTime createdAt,
                          String status,
                          List<OrderItemDTO> items) {
        this.id = id;
        this.userId = userId;
        this.userName = userName;
        this.totalAmount = totalAmount;
        this.createdAt = createdAt;
        this.status = status;
        this.items = items;
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

    public List<OrderItemDTO> getItems() {
        return items;
    }
}
