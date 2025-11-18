package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDateTime;

public class StoreResponseDto {
    
    private Long idStore;
    private String name;
    private String address;
    private String status;
    private String businessHours;
    private Long idCompany;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public StoreResponseDto() {}
    
    public StoreResponseDto(Long idStore, String name, String address, String status, String businessHours, Long idCompany, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idStore = idStore;
        this.name = name;
        this.address = address;
        this.status = status;
        this.businessHours = businessHours;
        this.idCompany = idCompany;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and setters
    public Long getIdStore() {
        return idStore;
    }
    
    public void setIdStore(Long idStore) {
        this.idStore = idStore;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getBusinessHours() {
        return businessHours;
    }
    
    public void setBusinessHours(String businessHours) {
        this.businessHours = businessHours;
    }
    
    public Long getIdCompany() {
        return idCompany;
    }
    
    public void setIdCompany(Long idCompany) {
        this.idCompany = idCompany;
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
