package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "detail_orders")
public class DetailOrderJpaEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_detail")
    private Long idDetail;
    
    @Column(name = "id_order", nullable = false)
    private Long idOrder;
    
    @Column(name = "id_product", nullable = false)
    private Long idProduct;
    
    @Column(name = "amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public DetailOrderJpaEntity() {}
    
    public DetailOrderJpaEntity(Long idOrder, Long idProduct, BigDecimal amount) {
        this.idOrder = idOrder;
        this.idProduct = idProduct;
        this.amount = amount;
    }
    
    public DetailOrderJpaEntity(Long idDetail, Long idOrder, Long idProduct, BigDecimal amount, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idDetail = idDetail;
        this.idOrder = idOrder;
        this.idProduct = idProduct;
        this.amount = amount;
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
    public Long getIdDetail() {
        return idDetail;
    }
    
    public void setIdDetail(Long idDetail) {
        this.idDetail = idDetail;
    }
    
    public Long getIdOrder() {
        return idOrder;
    }
    
    public void setIdOrder(Long idOrder) {
        this.idOrder = idOrder;
    }
    
    public Long getIdProduct() {
        return idProduct;
    }
    
    public void setIdProduct(Long idProduct) {
        this.idProduct = idProduct;
    }
    
    public BigDecimal getAmount() {
        return amount;
    }
    
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
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
