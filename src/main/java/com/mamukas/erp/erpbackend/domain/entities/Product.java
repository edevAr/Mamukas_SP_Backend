package com.mamukas.erp.erpbackend.domain.entities;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Product {
    
    private Long idProduct;
    private String name;
    private String status;
    private BigDecimal price;
    private LocalDate expirationDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public Product() {}
    
    public Product(String name, String status, BigDecimal price, LocalDate expirationDate) {
        this.name = name;
        this.status = status;
        this.price = price;
        this.expirationDate = expirationDate;
    }
    
    public Product(Long idProduct, String name, String status, BigDecimal price, LocalDate expirationDate, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idProduct = idProduct;
        this.name = name;
        this.status = status;
        this.price = price;
        this.expirationDate = expirationDate;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Business methods
    public void activate() {
        this.status = "Active";
    }
    
    public void deactivate() {
        this.status = "Inactive";
    }
    
    public boolean isActive() {
        return "Active".equals(this.status);
    }
    
    public boolean isInactive() {
        return "Inactive".equals(this.status);
    }
    
    public boolean isExpired() {
        return expirationDate != null && expirationDate.isBefore(LocalDate.now());
    }
    
    public boolean isExpiringSoon(int days) {
        return expirationDate != null && expirationDate.isBefore(LocalDate.now().plusDays(days));
    }
    
    // Validation methods
    public boolean isValidPrice() {
        return price != null && price.compareTo(BigDecimal.ZERO) >= 0;
    }
    
    public boolean hasValidName() {
        return name != null && !name.trim().isEmpty() && name.length() <= 255;
    }
    
    public boolean isValidStatus() {
        return status != null && (status.equals("Active") || status.equals("Inactive"));
    }
    
    // Getters and setters
    public Long getIdProduct() {
        return idProduct;
    }
    
    public void setIdProduct(Long idProduct) {
        this.idProduct = idProduct;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public BigDecimal getPrice() {
        return price;
    }
    
    public void setPrice(BigDecimal price) {
        this.price = price;
    }
    
    public LocalDate getExpirationDate() {
        return expirationDate;
    }
    
    public void setExpirationDate(LocalDate expirationDate) {
        this.expirationDate = expirationDate;
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
        return "Product{" +
                "idProduct=" + idProduct +
                ", name='" + name + '\'' +
                ", status='" + status + '\'' +
                ", price=" + price +
                ", expirationDate=" + expirationDate +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
