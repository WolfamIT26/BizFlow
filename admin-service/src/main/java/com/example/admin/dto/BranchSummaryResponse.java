package com.example.admin.dto;

import java.math.BigDecimal;
import java.util.List;

public class BranchSummaryResponse {
    private long totalBranches;
    private long activeBranches;
    private BigDecimal totalRevenue;
    private List<BranchRevenueSummary> branches;

    public BranchSummaryResponse() {
    }

    public BranchSummaryResponse(long totalBranches,
                                 long activeBranches,
                                 BigDecimal totalRevenue,
                                 List<BranchRevenueSummary> branches) {
        this.totalBranches = totalBranches;
        this.activeBranches = activeBranches;
        this.totalRevenue = totalRevenue;
        this.branches = branches;
    }

    public long getTotalBranches() {
        return totalBranches;
    }

    public void setTotalBranches(long totalBranches) {
        this.totalBranches = totalBranches;
    }

    public long getActiveBranches() {
        return activeBranches;
    }

    public void setActiveBranches(long activeBranches) {
        this.activeBranches = activeBranches;
    }

    public BigDecimal getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public List<BranchRevenueSummary> getBranches() {
        return branches;
    }

    public void setBranches(List<BranchRevenueSummary> branches) {
        this.branches = branches;
    }
}
