package com.example.bizflow.controller;

import com.example.bizflow.dto.InventoryReceiptRequest;
import com.example.bizflow.dto.InventoryReceiptResponse;
import com.example.bizflow.entity.InventoryStock;
import com.example.bizflow.repository.InventoryStockRepository;
import com.example.bizflow.service.InventoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/internal/inventory")
public class InventoryInternalController {

    private final InventoryService inventoryService;
    private final InventoryStockRepository inventoryStockRepository;

    public InventoryInternalController(InventoryService inventoryService,
                                       InventoryStockRepository inventoryStockRepository) {
        this.inventoryService = inventoryService;
        this.inventoryStockRepository = inventoryStockRepository;
    }

    @PostMapping("/sales")
    public ResponseEntity<Void> applySale(@RequestBody SaleRequest request) {
        if (request == null || request.items == null || request.items.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        inventoryService.applySale(request.orderId, toServiceItems(request.items), request.userId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/stocks")
    public ResponseEntity<List<StockItem>> getStocks(@RequestBody List<Long> productIds) {
        if (productIds == null || productIds.isEmpty()) {
            return ResponseEntity.ok(List.of());
        }
        List<StockItem> result = new ArrayList<>();
        for (Long productId : productIds) {
            int stock = inventoryStockRepository.findByProductId(productId)
                    .map(InventoryStock::getStock)
                    .orElse(0);
            StockItem item = new StockItem();
            item.productId = productId;
            item.stock = stock;
            result.add(item);
        }
        return ResponseEntity.ok(result);
    }

    @PostMapping("/receipts")
    public ResponseEntity<InventoryReceiptResponse> receiveStock(@RequestBody InventoryReceiptRequest request) {
        if (request == null || request.getProductId() == null) {
            return ResponseEntity.badRequest().build();
        }

        var tx = inventoryService.receiveStock(
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
                tx == null ? null : tx.getId()
        ));
    }

    private List<InventoryService.SaleItem> toServiceItems(List<SaleItem> items) {
        List<InventoryService.SaleItem> result = new ArrayList<>();
        for (SaleItem item : items) {
            InventoryService.SaleItem saleItem = new InventoryService.SaleItem();
            saleItem.setProductId(item.productId);
            saleItem.setQuantity(item.quantity);
            saleItem.setUnitPrice(item.unitPrice);
            result.add(saleItem);
        }
        return result;
    }

    private static class SaleRequest {
        public Long orderId;
        public Long userId;
        public List<SaleItem> items;
    }

    private static class SaleItem {
        public Long productId;
        public Integer quantity;
        public java.math.BigDecimal unitPrice;
    }

    public static class StockItem {
        public Long productId;
        public Integer stock;
    }
}
