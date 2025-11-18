package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "employee_warehouses")
public class EmployeeWarehouseJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_employee_warehouse")
    private Long idEmployeeWarehouse;

    @Column(name = "id_user", nullable = false)
    private Long idUser;

    @Column(name = "id_warehouse", nullable = false)
    private Long idWarehouse;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    // Constructors
    public EmployeeWarehouseJpaEntity() {}

    public EmployeeWarehouseJpaEntity(Long idUser, Long idWarehouse) {
        this.idUser = idUser;
        this.idWarehouse = idWarehouse;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
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
