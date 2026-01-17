package com.example.bizflow.controller;

import com.example.bizflow.dto.ProductDTO;
import com.example.bizflow.entity.Product;
import com.example.bizflow.entity.InventoryStock;
import com.example.bizflow.repository.InventoryStockRepository;
import com.example.bizflow.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

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
            boolean showCostPrice = true; // <--- Ép hiện luôn để test cho sướng;
            List<ProductDTO> dtos = products.stream()
                    .map(p -> ProductDTO.fromEntity(p, showCostPrice))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(dtos);
        } catch (Exception e) {
            try {
                List<Product> products = productRepository.findAll();
                applyInventoryStocks(products);
                boolean showCostPrice = true; // <--- Ép hiện luôn để test cho sướng;
                List<ProductDTO> dtos = products.stream()
                        .map(p -> ProductDTO.fromEntity(p, showCostPrice))
                        .collect(Collectors.toList());
                return ResponseEntity.ok(dtos);
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
                        boolean showCostPrice = true; // <--- Ép hiện luôn để test cho sướng;
                        return ResponseEntity.ok(ProductDTO.fromEntity(product, showCostPrice));
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
            return ResponseEntity.ok(ProductDTO.fromEntity(saved, true));
        } catch (Exception e) {
            return ResponseEntity.status(400).body("Error creating product: " + e.getMessage());
        }
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<?> updateProduct(@PathVariable @NonNull Long id, @RequestBody @NonNull Product product) {
        try {
            return productRepository.findById(id)
                    .map(existing -> {
                        existing.setName(product.getName());
                        existing.setCode(product.getCode());
                        existing.setBarcode(product.getBarcode());
                        existing.setPrice(product.getPrice());
                        existing.setCostPrice(product.getCostPrice());
                        existing.setUnit(product.getUnit());
                        existing.setDescription(product.getDescription());
                        existing.setCategoryId(product.getCategoryId());
                        existing.setStatus(product.getStatus());
                        Product saved = productRepository.save(existing);
                        return ResponseEntity.ok(ProductDTO.fromEntity(saved, true));
                    })
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.status(400).body("Error updating product: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<?> deleteProduct(@PathVariable @NonNull Long id) {
        try {
            return productRepository.findById(id)
                    .map(product -> {
                        // Soft delete - chuyển status thành inactive
                        product.setStatus("inactive");
                        productRepository.save(product);
                        return ResponseEntity.ok("Product deactivated successfully");
                    })
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.status(400).body("Error deleting product: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}/permanent")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> permanentDeleteProduct(@PathVariable @NonNull Long id) {
        try {
            if (!productRepository.existsById(id)) {
                return ResponseEntity.notFound().build();
            }
            // Xóa inventory stock trước
            inventoryStockRepository.findByProductId(id).ifPresent(inventoryStockRepository::delete);
            productRepository.deleteById(id);
            return ResponseEntity.ok("Product permanently deleted");
        } catch (Exception e) {
            return ResponseEntity.status(400).body("Error permanently deleting product: " + e.getMessage());
        }
    }

    // Trong ProductController.java
    private boolean hasOwnerOrAdminRole() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) {
            return false;
        }

        // DEBUG: In ra để xem chính xác Java nhận được chuỗi gì
        System.out.println("User Roles: " + auth.getAuthorities());

        return auth.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                // Sửa equals thành equalsIgnoreCase
                .anyMatch(role -> role.equalsIgnoreCase("OWNER") || role.equalsIgnoreCase("ADMIN"));
    }

    private void applyInventoryStocks(List<Product> products) {
        if (products == null || products.isEmpty()) {
            return;
        }
        List<Long> ids = products.stream()
                .map(Product::getId)
                .filter(id -> id != null)
                .collect(java.util.stream.Collectors.toList());
        if (ids.isEmpty()) {
            return;
        }
        List<InventoryStock> stocks = inventoryStockRepository.findByProductIdIn(ids);
        java.util.Map<Long, Integer> stockMap = new java.util.HashMap<>();
        for (InventoryStock stock : stocks) {
            if (stock.getProductId() != null) {
                stockMap.put(stock.getProductId(), stock.getStock() == null ? 0 : stock.getStock());
            }
        }
        for (Product product : products) {
            if (product == null || product.getId() == null) {
                continue;
            }
            Integer stockValue = stockMap.get(product.getId());
            if (stockValue != null) {
                product.setStock(stockValue);
            } else {
                product.setStock(0);
            }
        }
    }
}
