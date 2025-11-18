package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

public class Customer {
    
    private Long customerId;
    private String name;
    private String nit;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public Customer() {}
    
    public Customer(String name, String nit) {
        this.name = name;
        this.nit = nit;
    }
    
    public Customer(Long customerId, String name, String nit, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.customerId = customerId;
        this.name = name;
        this.nit = nit;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Business methods
    public boolean hasValidName() {
        return name != null && !name.trim().isEmpty() && name.length() <= 255;
    }
    
    public boolean hasValidNit() {
        return nit != null && !nit.trim().isEmpty() && nit.length() <= 50;
    }
    
    public boolean isValidCustomer() {
        return hasValidName() && hasValidNit();
    }
    
    public String getDisplayName() {
        return name + " (" + nit + ")";
    }
    
    // Getters and setters
    public Long getCustomerId() {
        return customerId;
    }
    
    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getNit() {
        return nit;
    }
    
    public void setNit(String nit) {
        this.nit = nit;
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
        return "Customer{" +
                "customerId=" + customerId +
                ", name='" + name + '\'' +
                ", nit='" + nit + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
