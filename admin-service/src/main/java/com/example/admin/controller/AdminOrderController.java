package com.example.admin.controller;

import com.example.admin.dto.AdminOrderDetail;
import com.example.admin.dto.AdminOrderSummary;
import com.example.admin.service.AdminOrderService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class AdminOrderController {
    private final AdminOrderService orderService;

    public AdminOrderController(AdminOrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping("/api/admin/orders")
    public ResponseEntity<List<AdminOrderSummary>> getOrders(
            @RequestParam(required = false) Long branchId,
            HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        List<AdminOrderSummary> orders = orderService.fetchOrderSummaries(branchId, authHeader);
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/api/admin/orders/{id}")
    public ResponseEntity<AdminOrderDetail> getOrderDetail(
            @PathVariable Long id,
            @RequestParam(required = false) String viewer,
            HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        AdminOrderDetail detail = orderService.fetchOrderDetail(id, authHeader, viewer);
        if (detail == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(detail);
    }
}
