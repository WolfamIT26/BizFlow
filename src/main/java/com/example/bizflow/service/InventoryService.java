package com.example.bizflow.service;

import com.example.bizflow.entity.InventoryTransaction;
import com.example.bizflow.entity.InventoryTransactionType;
import com.example.bizflow.entity.InventoryStock;
import com.example.bizflow.entity.Order;
import com.example.bizflow.entity.OrderItem;
import com.example.bizflow.entity.Product;
import com.example.bizflow.repository.InventoryTransactionRepository;
import com.example.bizflow.repository.InventoryStockRepository;
import com.example.bizflow.repository.ProductRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;

@Service
public class InventoryService {
    private final ProductRepository productRepository;
    private final InventoryTransactionRepository inventoryTransactionRepository;
    private final InventoryStockRepository inventoryStockRepository;

    public InventoryService(ProductRepository productRepository,
                            InventoryTransactionRepository inventoryTransactionRepository,
                            InventoryStockRepository inventoryStockRepository) {
        this.productRepository = productRepository;
        this.inventoryTransactionRepository = inventoryTransactionRepository;
        this.inventoryStockRepository = inventoryStockRepository;
    }

    @Transactional
    public InventoryTransaction receiveStock(Long productId, int quantity, BigDecimal unitPrice, String note, Long userId) {
        if (productId == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Product not found");
        }
        if (quantity <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Quantity must be > 0");
        }

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Product not found"));

        InventoryStock stockRow = inventoryStockRepository.findByProductId(productId).orElseGet(() -> {
            InventoryStock created = new InventoryStock();
            created.setProductId(productId);
            created.setStock(0);
            return created;
        });
        int current = stockRow.getStock() == null ? 0 : stockRow.getStock();
        int updated = current + quantity;
        stockRow.setStock(updated);
        stockRow.setUpdatedBy(userId);
        inventoryStockRepository.save(stockRow);

        InventoryTransaction tx = new InventoryTransaction();
        tx.setProductId(product.getId());
        tx.setTransactionType(InventoryTransactionType.IN);
        tx.setQuantity(quantity);
        tx.setUnitPrice(unitPrice);
        tx.setReferenceType("RECEIPT");
        tx.setNote(note);
        tx.setCreatedBy(userId);
        return inventoryTransactionRepository.save(tx);
    }

    public int getAvailableStock(Long productId) {
        if (productId == null) return 0;
        return inventoryStockRepository.findByProductId(productId)
                .map(InventoryStock::getStock)
                .orElse(0);
    }

    @Transactional
    public void applySale(Order order, List<OrderItem> items, Long userId) {
        if (order == null || items == null || items.isEmpty()) {
            return;
        }

        for (OrderItem item : items) {
            if (item == null || item.getProduct() == null) {
                continue;
            }
            int qty = item.getQuantity();
            if (qty <= 0) {
                continue;
            }

            Product product = item.getProduct();
            InventoryStock stockRow = inventoryStockRepository.findByProductId(product.getId())
                    .orElseGet(() -> {
                        InventoryStock created = new InventoryStock();
                        created.setProductId(product.getId());
                        created.setStock(0);
                        return created;
                    });
            int current = stockRow.getStock() == null ? 0 : stockRow.getStock();
            if (current < qty) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Insufficient stock for product: " + (product.getName() == null ? "unknown" : product.getName())
                );
            }

            int updated = current - qty;
            stockRow.setStock(updated);
            stockRow.setUpdatedBy(userId);
            inventoryStockRepository.save(stockRow);

            InventoryTransaction tx = new InventoryTransaction();
            tx.setProductId(product.getId());
            tx.setTransactionType(InventoryTransactionType.SALE);
            tx.setQuantity(qty);
            tx.setUnitPrice(item.getPrice());
            tx.setReferenceType("ORDER");
            tx.setReferenceId(order.getId());
            tx.setCreatedBy(userId);
            inventoryTransactionRepository.save(tx);
        }
    }
}
