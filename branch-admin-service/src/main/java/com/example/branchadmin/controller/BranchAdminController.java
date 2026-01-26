package com.example.branchadmin.controller;

import com.example.branchadmin.dto.BranchGrowthResponseDTO;
import com.example.branchadmin.dto.BranchSummaryDTO;
import com.example.branchadmin.dto.DashboardSummaryDTO;
import com.example.branchadmin.dto.RecentUserDTO;
import com.example.branchadmin.service.BranchAdminService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class BranchAdminController {
    private final BranchAdminService service;

    public BranchAdminController(BranchAdminService service) {
        this.service = service;
    }

    @GetMapping("/dashboard/admin-summary")
    public ResponseEntity<DashboardSummaryDTO> dashboardSummary() {
        return ResponseEntity.ok(service.dashboardSummary());
    }

    @GetMapping("/dashboard/recent-users")
    public ResponseEntity<List<RecentUserDTO>> recentUsers() {
        return ResponseEntity.ok(service.recentUsers());
    }

    @GetMapping("/dashboard/branches")
    public ResponseEntity<List<BranchSummaryDTO>> branchSummaries() {
        return ResponseEntity.ok(service.listBranchSummaries());
    }

    @GetMapping("/admin/branches/summary")
    public ResponseEntity<List<BranchSummaryDTO>> branchAdminSummary() {
        return ResponseEntity.ok(service.listBranchSummaries());
    }

    @GetMapping("/admin/branches/{id}/growth")
    public ResponseEntity<BranchGrowthResponseDTO> branchGrowth(@PathVariable("id") Long branchId) {
        return ResponseEntity.ok(service.branchGrowth(branchId));
    }
}
