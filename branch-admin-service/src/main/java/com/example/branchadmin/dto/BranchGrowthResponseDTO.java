package com.example.branchadmin.dto;

import java.util.List;

public class BranchGrowthResponseDTO {
    private final Long branchId;
    private final String branchName;
    private final List<BranchGrowthPointDTO> points;

    public BranchGrowthResponseDTO(Long branchId, String branchName, List<BranchGrowthPointDTO> points) {
        this.branchId = branchId;
        this.branchName = branchName;
        this.points = points;
    }

    public Long getBranchId() {
        return branchId;
    }

    public String getBranchName() {
        return branchName;
    }

    public List<BranchGrowthPointDTO> getPoints() {
        return points;
    }
}
