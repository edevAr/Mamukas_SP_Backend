package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "packs")
public class PackJpaEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_pack")
    private Long idPack;
    
    @Column(name = "id_product", nullable = false)
    private Long idProduct;
    
    @Column(name = "name", nullable = false, length = 255)
    private String name;
    
    @Column(name = "expiration_date")
    private LocalDate expirationDate;
    
    @Column(name = "units", nullable = false)
    private Integer units;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public PackJpaEntity() {}
    
    public PackJpaEntity(Long idProduct, String name, LocalDate expirationDate, Integer units) {
        this.idProduct = idProduct;
        this.name = name;
        this.expirationDate = expirationDate;
        this.units = units;
    }
    
    public PackJpaEntity(Long idPack, Long idProduct, String name, LocalDate expirationDate, Integer units, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idPack = idPack;
        this.idProduct = idProduct;
        this.name = name;
        this.expirationDate = expirationDate;
        this.units = units;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
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
