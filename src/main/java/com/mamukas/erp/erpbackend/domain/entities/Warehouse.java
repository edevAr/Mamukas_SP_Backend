package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

/**
 * Warehouse domain entity representing warehouse information
 */
public class Warehouse {
    
    private Long idWarehouse;
    private String address;
    private String status; // Active, Inactive
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public Warehouse() {}
    
    public Warehouse(String address, String status) {
        this.address = address;
        this.status = status;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    public Warehouse(Long idWarehouse, String address, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idWarehouse = idWarehouse;
        this.address = address;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Business methods
    public void activate() {
        this.status = "Active";
        this.updatedAt = LocalDateTime.now();
    }
    
    public void deactivate() {
        this.status = "Inactive";
        this.updatedAt = LocalDateTime.now();
    }
    
    public boolean isActive() {
        return "Active".equals(this.status);
    }
    
    public boolean isInactive() {
        return "Inactive".equals(this.status);
    }
    
    // Getters and setters
    public Long getIdWarehouse() {
        return idWarehouse;
    }
    
    public void setIdWarehouse(Long idWarehouse) {
        this.idWarehouse = idWarehouse;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
        this.updatedAt = LocalDateTime.now();
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();
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
