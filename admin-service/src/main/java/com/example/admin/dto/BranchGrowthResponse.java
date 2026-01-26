package com.example.admin.dto;

import java.util.List;

public class BranchGrowthResponse {
    private Long branchId;
    private String branchName;
    private List<BranchGrowthPoint> points;

    public BranchGrowthResponse() {
    }

    public BranchGrowthResponse(Long branchId, String branchName, List<BranchGrowthPoint> points) {
        this.branchId = branchId;
        this.branchName = branchName;
        this.points = points;
    }

    public Long getBranchId() {
        return branchId;
    }

    public void setBranchId(Long branchId) {
        this.branchId = branchId;
    }

    public String getBranchName() {
        return branchName;
    }

    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }

    public List<BranchGrowthPoint> getPoints() {
        return points;
    }

    public void setPoints(List<BranchGrowthPoint> points) {
        this.points = points;
    }
}
