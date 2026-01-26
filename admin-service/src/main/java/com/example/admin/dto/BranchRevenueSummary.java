package com.example.admin.dto;

import java.math.BigDecimal;

public class BranchRevenueSummary {
    private Long id;
    private String name;
    private String ownerName;
    private Boolean active;
    private BigDecimal totalRevenue;
    private long orderCount;

    public BranchRevenueSummary() {
    }

    public BranchRevenueSummary(Long id,
                                String name,
                                String ownerName,
                                Boolean active,
                                BigDecimal totalRevenue,
                                long orderCount) {
        this.id = id;
        this.name = name;
        this.ownerName = ownerName;
        this.active = active;
        this.totalRevenue = totalRevenue;
        this.orderCount = orderCount;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
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
