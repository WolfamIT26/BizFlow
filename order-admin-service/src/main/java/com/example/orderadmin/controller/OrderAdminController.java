package com.example.orderadmin.controller;

import com.example.orderadmin.dto.OrderDetailDTO;
import com.example.orderadmin.dto.OrderSummaryDTO;
import com.example.orderadmin.service.OrderAdminService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class OrderAdminController {
    private final OrderAdminService service;

    public OrderAdminController(OrderAdminService service) {
        this.service = service;
    }

    @GetMapping("/api/admin/orders")
    public ResponseEntity<List<OrderSummaryDTO>> listOrders(@RequestParam(required = false, defaultValue = "20") int limit) {
        return ResponseEntity.ok(service.listOrders(limit));
    }

    @GetMapping("/api/admin/orders/{id}")
    public ResponseEntity<OrderDetailDTO> getOrder(@PathVariable Long id) {
        OrderDetailDTO detail = service.getOrder(id);
        return detail == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(detail);
    }
}
