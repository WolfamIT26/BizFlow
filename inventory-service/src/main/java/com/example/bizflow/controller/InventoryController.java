package com.example.bizflow.controller;

import com.example.bizflow.entity.*;
import com.example.bizflow.repository.*;
import com.example.bizflow.service.InventoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/inventory")
public class InventoryController {
    
    @Autowired
    private InventoryService inventoryService;
    
    @Autowired
    private InventoryStockRepository inventoryStockRepository;
    
    // TODO: Call product-service via RestTemplate
    // private ProductRepository productRepository;
    
    @GetMapping("/stock")
    public ResponseEntity<?> getAllStock() {
        return ResponseEntity.ok(inventoryService.getAllStock());
    }
    
    @GetMapping("/stock/{productId}")
    public ResponseEntity<?> getStock(@PathVariable Long productId) {
        return ResponseEntity.ok(inventoryService.getStockByProductId(productId));
    }
    
    @PutMapping("/stock/{productId}")
    public ResponseEntity<?> updateStock(@PathVariable Long productId, @RequestParam Integer quantity) {
        return ResponseEntity.ok(inventoryService.updateStock(productId, quantity));
    }
    
    // TODO: More endpoints to integrate with product-service and order-service
}
