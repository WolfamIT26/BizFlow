package com.example.admin.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.admin.dto.BranchGrowthResponse;
import com.example.admin.dto.BranchSummaryResponse;
import com.example.admin.service.AdminBranchReportService;

@RestController
@RequestMapping("/api/admin/branches")
public class AdminBranchReportController {
    private final AdminBranchReportService reportService;

    public AdminBranchReportController(AdminBranchReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/summary")
    public BranchSummaryResponse getBranchSummary(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        return reportService.buildBranchSummary(authHeader);
    }

    @GetMapping("/{id}/growth")
    public BranchGrowthResponse getBranchGrowth(@PathVariable("id") Long branchId,
                                                @RequestParam(name = "months", defaultValue = "6") int months,
                                                @RequestHeader(value = "Authorization", required = false) String authHeader) {
        return reportService.buildBranchGrowth(branchId, months, authHeader);
    }
}
