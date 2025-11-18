package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class PackResponseDto {
    
    private Long idPack;
    private Long idProduct;
    private String name;
    private LocalDate expirationDate;
    private Integer units;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public PackResponseDto() {}
    
    public PackResponseDto(Long idPack, Long idProduct, String name, LocalDate expirationDate, Integer units, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idPack = idPack;
        this.idProduct = idProduct;
        this.name = name;
        this.expirationDate = expirationDate;
        this.units = units;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and setters
    public Long getIdPack() {
        return idPack;
    }
    
    public void setIdPack(Long idPack) {
        this.idPack = idPack;
    }
    
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
    
    public LocalDate getExpirationDate() {
        return expirationDate;
    }
    
    public void setExpirationDate(LocalDate expirationDate) {
        this.expirationDate = expirationDate;
    }
    
    public Integer getUnits() {
        return units;
    }
    
    public void setUnits(Integer units) {
        this.units = units;
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
