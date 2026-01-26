package com.example.bizflow.dto;

public class LowStockAlertDTO {
    // TODO: Define fields based on requirements
    private Long productId;
    private String productName;
    private Integer currentStock;
    private Integer minStock;
    private String alertLevel;
    
    public LowStockAlertDTO() {}
    
    public LowStockAlertDTO(Long productId, String productName, Integer currentStock, Integer minStock) {
        this.productId = productId;
        this.productName = productName;
        this.currentStock = currentStock;
        this.minStock = minStock;
    }
    
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public Integer getCurrentStock() { return currentStock; }
    public void setCurrentStock(Integer currentStock) { this.currentStock = currentStock; }
    public Integer getMinStock() { return minStock; }
    public void setMinStock(Integer minStock) { this.minStock = minStock; }
    public String getAlertLevel() { return alertLevel; }
    public void setAlertLevel(String alertLevel) { this.alertLevel = alertLevel; }
}
