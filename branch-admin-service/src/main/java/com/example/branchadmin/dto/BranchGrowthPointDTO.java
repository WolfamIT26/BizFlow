package com.example.branchadmin.dto;

import java.math.BigDecimal;

public class BranchGrowthPointDTO {
    private final String period;
    private final BigDecimal revenue;
    private final long orderCount;

    public BranchGrowthPointDTO(String period, BigDecimal revenue, long orderCount) {
        this.period = period;
        this.revenue = revenue;
        this.orderCount = orderCount;
    }

    public String getPeriod() {
        return period;
    }

    public BigDecimal getRevenue() {
        return revenue;
    }

    public long getOrderCount() {
        return orderCount;
    }
}
