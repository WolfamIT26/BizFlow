package com.example.branchadmin.dto;

import java.math.BigDecimal;

public class BranchSummaryDTO {
    private final Long branchId;
    private final String name;
    private final BigDecimal revenue;
    private final long orderCount;
    private final boolean active;

    public BranchSummaryDTO(Long branchId, String name, BigDecimal revenue, long orderCount, boolean active) {
        this.branchId = branchId;
        this.name = name;
        this.revenue = revenue;
        this.orderCount = orderCount;
        this.active = active;
    }

    public Long getBranchId() {
        return branchId;
    }

    public String getName() {
        return name;
    }

    public BigDecimal getRevenue() {
        return revenue;
    }

    public long getOrderCount() {
        return orderCount;
    }

    public boolean isActive() {
        return active;
    }
}
