package com.example.branchadmin.service;

import com.example.branchadmin.dto.BranchGrowthPointDTO;
import com.example.branchadmin.dto.BranchGrowthResponseDTO;
import com.example.branchadmin.dto.BranchSummaryDTO;
import com.example.branchadmin.dto.DashboardSummaryDTO;
import com.example.branchadmin.dto.RecentUserDTO;
import com.example.branchadmin.entity.BranchGrowthEntity;
import com.example.branchadmin.entity.BranchMetricsEntity;
import com.example.branchadmin.entity.RecentUserEntity;
import com.example.branchadmin.repository.BranchGrowthRepository;
import com.example.branchadmin.repository.BranchMetricsRepository;
import com.example.branchadmin.repository.RecentUserRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class BranchAdminService {
    private final BranchMetricsRepository metricsRepository;
    private final BranchGrowthRepository growthRepository;
    private final RecentUserRepository recentUserRepository;

    public BranchAdminService(BranchMetricsRepository metricsRepository,
                              BranchGrowthRepository growthRepository,
                              RecentUserRepository recentUserRepository) {
        this.metricsRepository = metricsRepository;
        this.growthRepository = growthRepository;
        this.recentUserRepository = recentUserRepository;
    }

    public List<BranchSummaryDTO> listBranchSummaries() {
        return metricsRepository.findAll().stream()
                .map(entity -> new BranchSummaryDTO(entity.getId(), entity.getName(), defaultZero(entity.getRevenue()), entity.getOrderCount(), entity.isActive()))
                .collect(Collectors.toList());
    }

    public BranchGrowthResponseDTO branchGrowth(Long branchId) {
        List<BranchGrowthPointDTO> points = growthRepository.findByBranchIdOrderByPeriodLabelDesc(branchId).stream()
                .map(entity -> new BranchGrowthPointDTO(entity.getPeriodLabel(), defaultZero(entity.getRevenue()), entity.getOrderCount()))
                .collect(Collectors.toList());
        String name = metricsRepository.findById(branchId).map(BranchMetricsEntity::getName).orElse(null);
        return new BranchGrowthResponseDTO(branchId, name, points);
    }

    public DashboardSummaryDTO dashboardSummary() {
        List<BranchMetricsEntity> metrics = metricsRepository.findAll();
        long totalOrders = metrics.stream().mapToLong(BranchMetricsEntity::getOrderCount).sum();
        BigDecimal revenue = metrics.stream().map(entity -> defaultZero(entity.getRevenue())).reduce(BigDecimal.ZERO, BigDecimal::add);
        int activeBranches = (int) metrics.stream().filter(BranchMetricsEntity::isActive).count();
        return new DashboardSummaryDTO(totalOrders, revenue, activeBranches);
    }

    public List<RecentUserDTO> recentUsers() {
        return recentUserRepository.findTop10ByOrderByRegisteredAtDesc().stream()
                .map(entity -> new RecentUserDTO(entity.getId(), entity.getFullName(), entity.getRegisteredAt()))
                .collect(Collectors.toList());
    }

    private BigDecimal defaultZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}
