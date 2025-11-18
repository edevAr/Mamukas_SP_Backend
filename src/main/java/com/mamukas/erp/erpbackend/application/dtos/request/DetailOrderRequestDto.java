package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;

public class DetailOrderRequestDto {
    
    @NotNull(message = "Order ID cannot be null")
    @Positive(message = "Order ID must be positive")
    private Long idOrder;
    
    @NotNull(message = "Product ID cannot be null")
    @Positive(message = "Product ID must be positive")
    private Long idProduct;
    
    @NotNull(message = "Amount cannot be null")
    @Positive(message = "Amount must be positive")
    private BigDecimal amount;
    
    // Constructors
    public DetailOrderRequestDto() {}
    
    public DetailOrderRequestDto(Long idOrder, Long idProduct, BigDecimal amount) {
        this.idOrder = idOrder;
        this.idProduct = idProduct;
        this.amount = amount;
    }
    
    // Getters and setters
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
}
