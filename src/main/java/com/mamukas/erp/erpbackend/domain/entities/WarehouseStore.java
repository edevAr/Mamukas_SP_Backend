package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

/**
 * WarehouseStore domain entity representing the relationship between warehouses and stores
 */
public class WarehouseStore {
    
    private Long idWarehouseStore;
    private Long idWarehouse;
    private Long idStore;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public WarehouseStore() {}
    
    public WarehouseStore(Long idWarehouse, Long idStore) {
        this.idWarehouse = idWarehouse;
        this.idStore = idStore;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    public WarehouseStore(Long idWarehouseStore, Long idWarehouse, Long idStore, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idWarehouseStore = idWarehouseStore;
        this.idWarehouse = idWarehouse;
        this.idStore = idStore;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and setters
    public Long getIdWarehouseStore() {
        return idWarehouseStore;
    }
    
    public void setIdWarehouseStore(Long idWarehouseStore) {
        this.idWarehouseStore = idWarehouseStore;
    }
    
    public Long getIdWarehouse() {
        return idWarehouse;
    }
    
    public void setIdWarehouse(Long idWarehouse) {
        this.idWarehouse = idWarehouse;
        this.updatedAt = LocalDateTime.now();
    }
    
    public Long getIdStore() {
        return idStore;
    }
    
    public void setIdStore(Long idStore) {
        this.idStore = idStore;
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
