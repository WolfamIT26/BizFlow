package com.example.bizflow.dto;

import java.math.BigDecimal;

public class CreateOrderResponse {
    private Long orderId;
    private BigDecimal totalAmount;
    private Integer itemCount;
    private Boolean paid;

    public CreateOrderResponse() {
    }

    public CreateOrderResponse(Long orderId, BigDecimal totalAmount, Integer itemCount, Boolean paid) {
        this.orderId = orderId;
        this.totalAmount = totalAmount;
        this.itemCount = itemCount;
        this.paid = paid;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public Integer getItemCount() {
        return itemCount;
    }

    public void setItemCount(Integer itemCount) {
        this.itemCount = itemCount;
    }

    public Boolean getPaid() {
        return paid;
    }

    public void setPaid(Boolean paid) {
        this.paid = paid;
    }
}
