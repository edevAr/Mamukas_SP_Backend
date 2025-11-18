package com.mamukas.erp.erpbackend.application.dtos.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class SaleResponseDto {
    private Long idSale;
    private LocalDateTime date;
    private Long idProduct;
    private Long idCustomer;
    private String productName;
    private String customerName;
    private Integer amount;
    private BigDecimal subtotal;
    private BigDecimal discount;
    private BigDecimal total;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public SaleResponseDto() {}

    public SaleResponseDto(Long idSale, LocalDateTime date, Long idProduct, Long idCustomer, 
                          Integer amount, BigDecimal subtotal, BigDecimal discount, BigDecimal total,
                          LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idSale = idSale;
        this.date = date;
        this.idProduct = idProduct;
        this.idCustomer = idCustomer;
        this.amount = amount;
        this.subtotal = subtotal;
        this.discount = discount;
        this.total = total;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public SaleResponseDto(Long idSale, LocalDateTime date, Long idProduct, Long idCustomer, 
                          String productName, String customerName,
                          Integer amount, BigDecimal subtotal, BigDecimal discount, BigDecimal total,
                          LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idSale = idSale;
        this.date = date;
        this.idProduct = idProduct;
        this.idCustomer = idCustomer;
        this.productName = productName;
        this.customerName = customerName;
        this.amount = amount;
        this.subtotal = subtotal;
        this.discount = discount;
        this.total = total;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and setters
    public Long getIdSale() {
        return idSale;
    }

    public void setIdSale(Long idSale) {
        this.idSale = idSale;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }

    public Long getIdProduct() {
        return idProduct;
    }

    public void setIdProduct(Long idProduct) {
        this.idProduct = idProduct;
    }

    public Long getIdCustomer() {
        return idCustomer;
    }

    public void setIdCustomer(Long idCustomer) {
        this.idCustomer = idCustomer;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public BigDecimal getDiscount() {
        return discount;
    }

    public void setDiscount(BigDecimal discount) {
        this.discount = discount;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
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
