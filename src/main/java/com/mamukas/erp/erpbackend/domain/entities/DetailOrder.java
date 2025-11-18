package com.mamukas.erp.erpbackend.domain.entities;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class DetailOrder {
    
    private Long idDetail;
    private Long idOrder;
    private Long idProduct;
    private BigDecimal amount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public DetailOrder() {}
    
    public DetailOrder(Long idOrder, Long idProduct, BigDecimal amount) {
        this.idOrder = idOrder;
        this.idProduct = idProduct;
        this.amount = amount;
    }
    
    public DetailOrder(Long idDetail, Long idOrder, Long idProduct, BigDecimal amount, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idDetail = idDetail;
        this.idOrder = idOrder;
        this.idProduct = idProduct;
        this.amount = amount;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Business methods
    public boolean hasValidAmount() {
        return amount != null && amount.compareTo(BigDecimal.ZERO) >= 0;
    }
    
    public boolean hasValidOrder() {
        return idOrder != null && idOrder > 0;
    }
    
    public boolean hasValidProduct() {
        return idProduct != null && idProduct > 0;
    }
    
    public boolean isValidDetail() {
        return hasValidAmount() && hasValidOrder() && hasValidProduct();
    }
    
    public void setAmountFromDouble(Double amountValue) {
        if (amountValue != null) {
            this.amount = BigDecimal.valueOf(amountValue);
        }
    }
    
    // Getters and setters
    public Long getIdDetail() {
        return idDetail;
    }
    
    public void setIdDetail(Long idDetail) {
        this.idDetail = idDetail;
    }
    
    public Long getIdOrder() {
        return idOrder;
    }
    
    public void setIdOrder(Long idOrder) {
        this.idOrder = idOrder;
    }
    
    public Long getIdProduct() {
        return idProduct;
    }
    
    public void setIdProduct(Long idProduct) {
        this.idProduct = idProduct;
    }
    
    public BigDecimal getAmount() {
        return amount;
    }
    
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    @Override
    public String toString() {
        return "DetailOrder{" +
                "idDetail=" + idDetail +
                ", idOrder=" + idOrder +
                ", idProduct=" + idProduct +
                ", amount=" + amount +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
