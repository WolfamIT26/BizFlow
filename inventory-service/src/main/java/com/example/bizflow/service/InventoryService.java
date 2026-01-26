package com.example.bizflow.service;

import com.example.bizflow.entity.*;
import com.example.bizflow.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class InventoryService {
    
    @Autowired
    private InventoryStockRepository inventoryStockRepository;
    
    @Autowired
    private InventoryTransactionRepository inventoryTransactionRepository;
    
    // TODO: Call product-service via RestTemplate
    // private ProductRepository productRepository;
    
    public List<InventoryStock> getAllStock() {
        return inventoryStockRepository.findAll();
    }
    
    public Optional<InventoryStock> getStockByProductId(Long productId) {
        return inventoryStockRepository.findByProductId(productId);
    }
    
    public InventoryStock updateStock(Long productId, Integer quantity) {
        InventoryStock stock = inventoryStockRepository.findByProductId(productId)
            .orElse(new InventoryStock());
        stock.setProductId(productId);
        stock.setStock(quantity);
        return inventoryStockRepository.save(stock);
    }
    
    // TODO: Other methods will call product-service and order-service via API
}
