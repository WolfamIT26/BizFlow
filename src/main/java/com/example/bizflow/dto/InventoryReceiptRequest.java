package com.example.bizflow.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class InventoryReceiptRequest {
    private Long productId;
    private Integer quantity;
    private BigDecimal unitPrice;
    private String note;
    private Long userId;
}
