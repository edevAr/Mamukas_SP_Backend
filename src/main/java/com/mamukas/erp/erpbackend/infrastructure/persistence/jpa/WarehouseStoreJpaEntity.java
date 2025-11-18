package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "warehouse_stores")
public class WarehouseStoreJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_warehouse_store")
    private Long idWarehouseStore;

    @Column(name = "id_warehouse", nullable = false)
    private Long idWarehouse;

    @Column(name = "id_store", nullable = false)
    private Long idStore;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    // Constructors
    public WarehouseStoreJpaEntity() {}

    public WarehouseStoreJpaEntity(Long idWarehouse, Long idStore) {
        this.idWarehouse = idWarehouse;
        this.idStore = idStore;
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
    public Long getIdWarehouseStore() {
        return idWarehouseStore;
    }

    public void setIdWarehouseStore(Long idWarehouseStore) {
        this.idWarehouseStore = idWarehouseStore;
    }

    public Long getIdWarehouse() {
        return idWarehouse;
    }

    public void setIdWarehouse(Long idWarehouse) {
        this.idWarehouse = idWarehouse;
    }

    public Long getIdStore() {
        return idStore;
    }

    public void setIdStore(Long idStore) {
        this.idStore = idStore;
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
