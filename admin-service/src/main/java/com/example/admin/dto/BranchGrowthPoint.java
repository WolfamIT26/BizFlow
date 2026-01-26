package com.example.admin.dto;

import java.math.BigDecimal;

public class BranchGrowthPoint {
    private String label;
    private BigDecimal totalRevenue;
    private long orderCount;

    public BranchGrowthPoint() {
    }

    public BranchGrowthPoint(String label, BigDecimal totalRevenue, long orderCount) {
        this.label = label;
        this.totalRevenue = totalRevenue;
        this.orderCount = orderCount;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public BigDecimal getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public long getOrderCount() {
        return orderCount;
    }

    public void setOrderCount(long orderCount) {
        this.orderCount = orderCount;
    }
}
