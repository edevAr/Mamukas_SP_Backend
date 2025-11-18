package com.mamukas.erp.erpbackend.application.dtos.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class DetailOrderResponseDto {
    
    private Long idDetail;
    private Long idOrder;
    private Long idProduct;
    private BigDecimal amount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public DetailOrderResponseDto() {}
    
    public DetailOrderResponseDto(Long idDetail, Long idOrder, Long idProduct, BigDecimal amount, 
                                LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idDetail = idDetail;
        this.idOrder = idOrder;
        this.idProduct = idProduct;
        this.amount = amount;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
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
}
