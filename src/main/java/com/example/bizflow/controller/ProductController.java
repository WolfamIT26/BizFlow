package com.example.bizflow.controller;

import com.example.bizflow.entity.Product;
import com.example.bizflow.entity.InventoryStock;
import com.example.bizflow.repository.InventoryStockRepository;
import com.example.bizflow.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {
    
    @Autowired
    private ProductRepository productRepository;
    @Autowired
    private InventoryStockRepository inventoryStockRepository;
    
    @GetMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'OWNER', 'ADMIN')")
    public ResponseEntity<?> getAllProducts() {
        try {
            List<Product> products = productRepository.findByStatus("active");
            applyInventoryStocks(products);
            return ResponseEntity.ok(products);
        } catch (Exception e) {
            try {
                List<Product> products = productRepository.findAll();
                applyInventoryStocks(products);
                return ResponseEntity.ok(products);
            } catch (Exception fallback) {
                return ResponseEntity.status(500).body("Error fetching products: " + e.getMessage());
            }
        }
    }
    
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'OWNER', 'ADMIN')")
    public ResponseEntity<?> getProductById(@PathVariable @NonNull Long id) {
        try {
            return productRepository.findById(id)
                    .map(product -> {
                        applyInventoryStocks(List.of(product));
                        return ResponseEntity.ok(product);
                    })
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error fetching product: " + e.getMessage());
        }
    }
    
    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<?> createProduct(@RequestBody @NonNull Product product) {
        try {
            Product saved = productRepository.save(product);
            InventoryStock stock = new InventoryStock();
            stock.setProductId(saved.getId());
            stock.setStock(20);
            inventoryStockRepository.save(stock);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            return ResponseEntity.status(400).body("Error creating product: " + e.getMessage());
        }
    }

    private void applyInventoryStocks(List<Product> products) {
        if (products == null || products.isEmpty()) return;
        List<Long> ids = products.stream()
                .map(Product::getId)
                .filter(id -> id != null)
                .collect(java.util.stream.Collectors.toList());
        if (ids.isEmpty()) return;
        List<InventoryStock> stocks = inventoryStockRepository.findByProductIdIn(ids);
        java.util.Map<Long, Integer> stockMap = new java.util.HashMap<>();
        for (InventoryStock stock : stocks) {
            if (stock.getProductId() != null) {
                stockMap.put(stock.getProductId(), stock.getStock() == null ? 0 : stock.getStock());
            }
        }
        for (Product product : products) {
            if (product == null || product.getId() == null) continue;
            Integer stockValue = stockMap.get(product.getId());
            if (stockValue != null) {
                product.setStock(stockValue);
            } else {
                product.setStock(0);
            }
        }
    }
}
