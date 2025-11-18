package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class EntryOrderResponseDto {
    
    private Long idOrder;
    private Long idProvider;
    private LocalDate date;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public EntryOrderResponseDto() {}
    
    public EntryOrderResponseDto(Long idOrder, Long idProvider, LocalDate date, String status, 
                               LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idOrder = idOrder;
        this.idProvider = idProvider;
        this.date = date;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and setters
    public Long getIdOrder() {
        return idOrder;
    }
    
    public void setIdOrder(Long idOrder) {
        this.idOrder = idOrder;
    }
    
    public Long getIdProvider() {
        return idProvider;
    }
    
    public void setIdProvider(Long idProvider) {
        this.idProvider = idProvider;
    }
    
    public LocalDate getDate() {
        return date;
    }
    
    public void setDate(LocalDate date) {
        this.date = date;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
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
