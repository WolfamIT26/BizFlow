package com.example.bizflow.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
public class InventoryHistoryItem {
    private Long id;
    private Long productId;
    private String productName;
    private String type;
    private Integer quantity;
    private BigDecimal unitPrice;
    private String note;
    private String createdAt;
}
