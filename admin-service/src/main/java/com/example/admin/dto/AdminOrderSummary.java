package com.example.admin.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class AdminOrderSummary {
    private Long id;
    private Long userId;
    private String userName;
    private Long customerId;
    private String customerName;
    private String customerPhone;
    private BigDecimal totalAmount;
    private LocalDateTime createdAt;
    private Integer itemCount;
    private String invoiceNumber;
    private String status;
    private String note;
    private Long branchId;
    private String branchName;

    public AdminOrderSummary() {
    }

    public AdminOrderSummary(Long id,
                             Long userId,
                             String userName,
                             Long customerId,
                             String customerName,
                             String customerPhone,
                             BigDecimal totalAmount,
                             LocalDateTime createdAt,
                             Integer itemCount,
                             String invoiceNumber,
                             String status,
                             String note,
                             Long branchId,
                             String branchName) {
        this.id = id;
        this.userId = userId;
        this.userName = userName;
        this.customerId = customerId;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.totalAmount = totalAmount;
        this.createdAt = createdAt;
        this.itemCount = itemCount;
        this.invoiceNumber = invoiceNumber;
        this.status = status;
        this.note = note;
        this.branchId = branchId;
        this.branchName = branchName;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getItemCount() {
        return itemCount;
    }

    public void setItemCount(Integer itemCount) {
        this.itemCount = itemCount;
    }

    public String getInvoiceNumber() {
        return invoiceNumber;
    }

    public void setInvoiceNumber(String invoiceNumber) {
        this.invoiceNumber = invoiceNumber;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Long getBranchId() {
        return branchId;
    }

    public void setBranchId(Long branchId) {
        this.branchId = branchId;
    }

    public String getBranchName() {
        return branchName;
    }

    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }
}
