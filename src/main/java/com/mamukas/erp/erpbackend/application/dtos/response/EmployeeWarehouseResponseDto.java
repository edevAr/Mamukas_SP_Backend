package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDateTime;

public class EmployeeWarehouseResponseDto {
    
    private Long idEmployeeWarehouse;
    private Long idUser;
    private Long idWarehouse;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public EmployeeWarehouseResponseDto() {}
    
    public EmployeeWarehouseResponseDto(Long idEmployeeWarehouse, Long idUser, Long idWarehouse, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idEmployeeWarehouse = idEmployeeWarehouse;
        this.idUser = idUser;
        this.idWarehouse = idWarehouse;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and setters
    public Long getIdEmployeeWarehouse() {
        return idEmployeeWarehouse;
    }
    
    public void setIdEmployeeWarehouse(Long idEmployeeWarehouse) {
        this.idEmployeeWarehouse = idEmployeeWarehouse;
    }
    
    public Long getIdUser() {
        return idUser;
    }
    
    public void setIdUser(Long idUser) {
        this.idUser = idUser;
    }
    
    public Long getIdWarehouse() {
        return idWarehouse;
    }
    
    public void setIdWarehouse(Long idWarehouse) {
        this.idWarehouse = idWarehouse;
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
