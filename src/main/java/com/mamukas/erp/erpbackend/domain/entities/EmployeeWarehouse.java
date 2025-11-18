package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

/**
 * EmployeeWarehouse domain entity representing the relationship between employees and warehouses
 */
public class EmployeeWarehouse {
    
    private Long idEmployeeWarehouse;
    private Long idUser;
    private Long idWarehouse;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public EmployeeWarehouse() {}
    
    public EmployeeWarehouse(Long idUser, Long idWarehouse) {
        this.idUser = idUser;
        this.idWarehouse = idWarehouse;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    public EmployeeWarehouse(Long idEmployeeWarehouse, Long idUser, Long idWarehouse, LocalDateTime createdAt, LocalDateTime updatedAt) {
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
        this.updatedAt = LocalDateTime.now();
    }
    
    public Long getIdWarehouse() {
        return idWarehouse;
    }
    
    public void setIdWarehouse(Long idWarehouse) {
        this.idWarehouse = idWarehouse;
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
