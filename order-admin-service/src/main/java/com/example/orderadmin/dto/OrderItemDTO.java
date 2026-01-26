package com.example.orderadmin.dto;

import java.math.BigDecimal;

public class OrderItemDTO {
    private final Long id;
    private final Long productId;
    private final String productName;
    private final BigDecimal lineTotal;
    private final Integer quantity;

    public OrderItemDTO(Long id, Long productId, String productName, BigDecimal lineTotal, Integer quantity) {
        this.id = id;
        this.productId = productId;
        this.productName = productName;
        this.lineTotal = lineTotal;
        this.quantity = quantity;
    }

    public Long getId() {
        return id;
    }

    public Long getProductId() {
        return productId;
    }

    public String getProductName() {
        return productName;
    }

    public BigDecimal getLineTotal() {
        return lineTotal;
    }

    public Integer getQuantity() {
        return quantity;
    }
}
