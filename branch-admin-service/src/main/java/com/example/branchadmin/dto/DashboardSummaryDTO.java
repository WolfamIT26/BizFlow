package com.example.branchadmin.dto;

import java.math.BigDecimal;

public class DashboardSummaryDTO {
    private final long totalOrders;
    private final BigDecimal revenue;
    private final int activeBranches;

    public DashboardSummaryDTO(long totalOrders, BigDecimal revenue, int activeBranches) {
        this.totalOrders = totalOrders;
        this.revenue = revenue;
        this.activeBranches = activeBranches;
    }

    public long getTotalOrders() {
        return totalOrders;
    }

    public BigDecimal getRevenue() {
        return revenue;
    }

    public int getActiveBranches() {
        return activeBranches;
    }
}
