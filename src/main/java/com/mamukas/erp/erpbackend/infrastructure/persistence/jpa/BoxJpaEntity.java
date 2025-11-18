package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "boxes")
public class BoxJpaEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_box")
    private Long idBox;
    
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
    public BoxJpaEntity() {}
    
    public BoxJpaEntity(Long idProduct, String name, LocalDate expirationDate, Integer units) {
        this.idProduct = idProduct;
        this.name = name;
        this.expirationDate = expirationDate;
        this.units = units;
    }
    
    public BoxJpaEntity(Long idBox, Long idProduct, String name, LocalDate expirationDate, Integer units, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idBox = idBox;
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
    public Long getIdBox() {
        return idBox;
    }
    
    public void setIdBox(Long idBox) {
        this.idBox = idBox;
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
