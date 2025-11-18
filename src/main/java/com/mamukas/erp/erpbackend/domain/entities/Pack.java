package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Pack {
    
    private Long idPack;
    private Long idProduct;
    private String name;
    private LocalDate expirationDate;
    private Integer units;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public Pack() {}
    
    public Pack(Long idProduct, String name, LocalDate expirationDate, Integer units) {
        this.idProduct = idProduct;
        this.name = name;
        this.expirationDate = expirationDate;
        this.units = units;
    }
    
    public Pack(Long idPack, Long idProduct, String name, LocalDate expirationDate, Integer units, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idPack = idPack;
        this.idProduct = idProduct;
        this.name = name;
        this.expirationDate = expirationDate;
        this.units = units;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Business methods
    public boolean isExpired() {
        return expirationDate != null && expirationDate.isBefore(LocalDate.now());
    }
    
    public boolean isExpiringSoon(int days) {
        return expirationDate != null && expirationDate.isBefore(LocalDate.now().plusDays(days));
    }
    
    public boolean hasValidUnits() {
        return units != null && units > 0;
    }
    
    public boolean hasStock() {
        return hasValidUnits() && units > 0;
    }
    
    public void addUnits(int additionalUnits) {
        if (additionalUnits > 0) {
            this.units = (this.units == null ? 0 : this.units) + additionalUnits;
        }
    }
    
    public void removeUnits(int unitsToRemove) {
        if (unitsToRemove > 0 && this.units != null && this.units >= unitsToRemove) {
            this.units -= unitsToRemove;
        } else {
            throw new RuntimeException("Insufficient units in pack");
        }
    }
    
    // Validation methods
    public boolean hasValidName() {
        return name != null && !name.trim().isEmpty() && name.length() <= 255;
    }
    
    public boolean hasValidProductReference() {
        return idProduct != null && idProduct > 0;
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
    
    @Override
    public String toString() {
        return "Pack{" +
                "idPack=" + idPack +
                ", idProduct=" + idProduct +
                ", name='" + name + '\'' +
                ", expirationDate=" + expirationDate +
                ", units=" + units +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
