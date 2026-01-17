package com.example.bizflow.service;

import com.example.bizflow.dto.ProductCostHistoryDTO;
import com.example.bizflow.dto.ProductCostUpdateRequest;
import com.example.bizflow.entity.Product;
import com.example.bizflow.entity.ProductCost;
import com.example.bizflow.entity.ProductCostHistory;
import com.example.bizflow.entity.InventoryStock;
import com.example.bizflow.entity.InventoryTransaction;
import com.example.bizflow.entity.InventoryTransactionType;
import com.example.bizflow.repository.ProductCostHistoryRepository;
import com.example.bizflow.repository.ProductCostRepository;
import com.example.bizflow.repository.ProductRepository;
import com.example.bizflow.repository.InventoryStockRepository;
import com.example.bizflow.repository.InventoryTransactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ProductCostService {

    private final ProductCostRepository productCostRepository;
    private final ProductCostHistoryRepository costHistoryRepository;
    private final ProductRepository productRepository;
    private final InventoryStockRepository inventoryStockRepository;
    private final InventoryTransactionRepository inventoryTransactionRepository;

    public ProductCostService(ProductCostRepository productCostRepository,
            ProductCostHistoryRepository costHistoryRepository,
            ProductRepository productRepository,
            InventoryStockRepository inventoryStockRepository,
            InventoryTransactionRepository inventoryTransactionRepository) {
        this.productCostRepository = productCostRepository;
        this.costHistoryRepository = costHistoryRepository;
        this.productRepository = productRepository;
        this.inventoryStockRepository = inventoryStockRepository;
        this.inventoryTransactionRepository = inventoryTransactionRepository;
    }

    /**
     * Lấy giá vốn hiện tại của sản phẩm
     */
    public Optional<BigDecimal> getCurrentCostPrice(Long productId) {
        return productCostRepository.findByProductId(productId)
                .map(ProductCost::getCostPrice);
    }

    /**
     * Lấy thông tin giá vốn của sản phẩm
     */
    public Optional<ProductCost> getProductCost(Long productId) {
        return productCostRepository.findByProductId(productId);
    }

    /**
     * Cập nhật giá vốn khi nhập hàng - tự động lưu lịch sử và cập nhật tồn kho
     */
    @Transactional
    public ProductCost updateCostPrice(ProductCostUpdateRequest request, Long userId) {
        Long productId = request.getProductId();
        BigDecimal newCostPrice = request.getCostPrice();
        Integer quantity = request.getQuantity() != null ? request.getQuantity() : 0;
        String note = request.getNote();

        // 1. Cập nhật hoặc tạo mới giá vốn hiện tại trong product_costs
        ProductCost productCost = productCostRepository.findByProductId(productId)
                .orElse(new ProductCost(productId, newCostPrice));

        productCost.setCostPrice(newCostPrice);
        productCost = productCostRepository.save(productCost);

        // 2. Cập nhật giá vốn trong bảng products (để đồng bộ)
        Optional<Product> optProduct = productRepository.findById(productId);
        if (optProduct.isPresent()) {
            Product product = optProduct.get();
            product.setCostPrice(newCostPrice);
            productRepository.saveAndFlush(product);
        }

        // 3. Cập nhật tồn kho trong inventory_stock nếu có số lượng nhập
        if (quantity > 0) {
            updateInventoryStock(productId, quantity, newCostPrice, note, userId);
        }

        // 4. Lưu vào lịch sử nhập hàng
        ProductCostHistory history = new ProductCostHistory(
                productId, newCostPrice, quantity, note, userId);
        costHistoryRepository.save(history);

        return productCost;
    }

    /**
     * Cập nhật tồn kho khi nhập hàng
     */
    @Transactional
    public void updateInventoryStock(Long productId, Integer quantityIn, BigDecimal costPrice, String note, Long userId) {
        // Cập nhật inventory_stock
        InventoryStock stock = inventoryStockRepository.findByProductId(productId)
                .orElseGet(() -> {
                    InventoryStock newStock = new InventoryStock();
                    newStock.setProductId(productId);
                    newStock.setStock(0);
                    return newStock;
                });

        int oldStock = stock.getStock() != null ? stock.getStock() : 0;
        int newStock = oldStock + quantityIn;
        stock.setStock(newStock);
        inventoryStockRepository.save(stock);

        // Cập nhật stock trong bảng products (đồng bộ)
        productRepository.findById(productId).ifPresent(product -> {
            int productOldStock = product.getStock() != null ? product.getStock() : 0;
            product.setStock(productOldStock + quantityIn);
            productRepository.save(product);
        });

        // Tạo transaction nhập kho
        InventoryTransaction transaction = new InventoryTransaction();
        transaction.setProductId(productId);
        transaction.setTransactionType(InventoryTransactionType.IN);
        transaction.setQuantity(quantityIn);
        transaction.setNote(note != null ? note : "Nhập hàng - Giá vốn: " + costPrice);
        transaction.setCreatedBy(userId);
        transaction.setCreatedAt(LocalDateTime.now());
        inventoryTransactionRepository.save(transaction);
    }

    /**
     * Nhập hàng với giá vốn mới
     */
    @Transactional
    public ProductCostHistory recordPurchase(Long productId, BigDecimal costPrice,
            Integer quantity, String note, Long userId) {
        ProductCostUpdateRequest request = new ProductCostUpdateRequest();
        request.setProductId(productId);
        request.setCostPrice(costPrice);
        request.setQuantity(quantity);
        request.setNote(note);

        updateCostPrice(request, userId);

        // Trả về lịch sử vừa tạo
        List<ProductCostHistory> histories = costHistoryRepository
                .findByProductIdOrderByCreatedAtDesc(productId);
        return histories.isEmpty() ? null : histories.get(0);
    }

    /**
     * Lấy lịch sử giá vốn của một sản phẩm
     */
    public List<ProductCostHistoryDTO> getCostHistory(Long productId) {
        return costHistoryRepository.findByProductIdOrderByCreatedAtDesc(productId)
                .stream()
                .map(ProductCostHistoryDTO::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Lấy tất cả lịch sử nhập hàng
     */
    public List<ProductCostHistoryDTO> getAllCostHistory() {
        return costHistoryRepository.findAllWithProduct()
                .stream()
                .map(ProductCostHistoryDTO::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Lấy lịch sử theo khoảng thời gian
     */
    public List<ProductCostHistoryDTO> getCostHistoryByDateRange(LocalDate startDate, LocalDate endDate) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(LocalTime.MAX);

        return costHistoryRepository.findByDateRange(start, end)
                .stream()
                .map(ProductCostHistoryDTO::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Lấy lịch sử của sản phẩm theo khoảng thời gian
     */
    public List<ProductCostHistoryDTO> getProductCostHistoryByDateRange(
            Long productId, LocalDate startDate, LocalDate endDate) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(LocalTime.MAX);

        return costHistoryRepository.findByProductIdAndDateRange(productId, start, end)
                .stream()
                .map(ProductCostHistoryDTO::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Khởi tạo giá vốn từ bảng products (migration)
     */
    @Transactional
    public void initializeCostsFromProducts() {
        List<Product> products = productRepository.findAll();
        for (Product product : products) {
            if (product.getCostPrice() != null && product.getCostPrice().compareTo(BigDecimal.ZERO) > 0) {
                if (!productCostRepository.existsByProductId(product.getId())) {
                    ProductCost cost = new ProductCost(product.getId(), product.getCostPrice());
                    productCostRepository.save(cost);
                }
            }
        }
    }
}
