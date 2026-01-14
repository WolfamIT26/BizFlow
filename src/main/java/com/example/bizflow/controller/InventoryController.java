package com.example.bizflow.controller;

import com.example.bizflow.dto.InventoryHistoryItem;
import com.example.bizflow.dto.InventoryReceiptRequest;
import com.example.bizflow.dto.InventoryReceiptResponse;
import com.example.bizflow.entity.InventoryTransaction;
import com.example.bizflow.entity.Product;
import com.example.bizflow.repository.InventoryTransactionRepository;
import com.example.bizflow.repository.ProductRepository;
import com.example.bizflow.service.InventoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/inventory")
public class InventoryController {
    private static final DateTimeFormatter HISTORY_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final ProductRepository productRepository;
    private final InventoryTransactionRepository inventoryTransactionRepository;
    private final InventoryService inventoryService;

    public InventoryController(ProductRepository productRepository,
                               InventoryTransactionRepository inventoryTransactionRepository,
                               InventoryService inventoryService) {
        this.productRepository = productRepository;
        this.inventoryTransactionRepository = inventoryTransactionRepository;
        this.inventoryService = inventoryService;
    }

    @PostMapping("/receipts")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'OWNER', 'ADMIN')")
    public ResponseEntity<?> receiveStock(@RequestBody InventoryReceiptRequest request) {
        if (request == null || request.getProductId() == null) {
            return ResponseEntity.badRequest().body("Product is required");
        }

        InventoryTransaction tx = inventoryService.receiveStock(
                request.getProductId(),
                request.getQuantity() == null ? 0 : request.getQuantity(),
                request.getUnitPrice(),
                request.getNote(),
                request.getUserId()
        );

        int stock = inventoryService.getAvailableStock(request.getProductId());

        return ResponseEntity.ok(new InventoryReceiptResponse(
                request.getProductId(),
                stock,
                tx.getId()
        ));
    }

    @GetMapping("/history")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'OWNER', 'ADMIN')")
    public ResponseEntity<?> getHistory(@RequestParam(name = "productId") Long productId) {
        if (productId == null) {
            return ResponseEntity.badRequest().body("Product is required");
        }

        Product product = productRepository.findById(productId).orElse(null);
        String productName = product == null ? null : product.getName();
        List<InventoryTransaction> history = inventoryTransactionRepository
                .findTop50ByProductIdOrderByCreatedAtDesc(productId);
        List<InventoryHistoryItem> items = new ArrayList<>();

        for (InventoryTransaction tx : history) {
            String createdAt = tx.getCreatedAt() == null ? null : tx.getCreatedAt().format(HISTORY_FORMAT);
            items.add(new InventoryHistoryItem(
                    tx.getId(),
                    tx.getProductId(),
                    productName,
                    tx.getTransactionType() == null ? null : tx.getTransactionType().name(),
                    tx.getQuantity(),
                    tx.getUnitPrice(),
                    tx.getNote(),
                    createdAt
            ));
        }

        return ResponseEntity.ok(items);
    }
}
