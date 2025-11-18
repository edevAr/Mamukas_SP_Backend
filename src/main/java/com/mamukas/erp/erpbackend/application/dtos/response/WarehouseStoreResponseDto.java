package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDateTime;

public class WarehouseStoreResponseDto {
    
    private Long idWarehouseStore;
    private Long idWarehouse;
    private Long idStore;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public WarehouseStoreResponseDto() {}
    
    public WarehouseStoreResponseDto(Long idWarehouseStore, Long idWarehouse, Long idStore, LocalDateTime createdAt, LocalDateTime updatedAt) {
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
    }
    
    public Long getIdStore() {
        return idStore;
    }
    
    public void setIdStore(Long idStore) {
        this.idStore = idStore;
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
