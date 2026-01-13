package com.example.bizflow.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class InventoryReceiptResponse {
    private Long productId;
    private Integer newStock;
    private Long transactionId;
}
