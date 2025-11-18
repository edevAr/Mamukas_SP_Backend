package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "exit_orders")
public class ExitOrderJpaEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_order")
    private Long idOrder;
    
    @Column(name = "id_customer", nullable = false)
    private Long idCustomer;
    
    @Column(name = "date", nullable = false)
    private LocalDate date;
    
    @Column(name = "status", nullable = false, length = 50)
    private String status;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public ExitOrderJpaEntity() {}
    
    public ExitOrderJpaEntity(Long idCustomer, LocalDate date, String status) {
        this.idCustomer = idCustomer;
        this.date = date;
        this.status = status;
    }
    
    public ExitOrderJpaEntity(Long idOrder, Long idCustomer, LocalDate date, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idOrder = idOrder;
        this.idCustomer = idCustomer;
        this.date = date;
        this.status = status;
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
    public Long getIdOrder() {
        return idOrder;
    }
    
    public void setIdOrder(Long idOrder) {
        this.idOrder = idOrder;
    }
    
    public Long getIdCustomer() {
        return idCustomer;
    }
    
    public void setIdCustomer(Long idCustomer) {
        this.idCustomer = idCustomer;
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
