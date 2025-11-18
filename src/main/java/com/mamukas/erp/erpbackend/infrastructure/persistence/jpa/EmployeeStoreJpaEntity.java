package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "employee_stores")
public class EmployeeStoreJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_employee_store")
    private Long idEmployeeStore;

    @Column(name = "id_employee", nullable = false)
    private Long idEmployee;

    @Column(name = "id_store", nullable = false)
    private Long idStore;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public EmployeeStoreJpaEntity() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor for creation
    public EmployeeStoreJpaEntity(Long idEmployee, Long idStore) {
        this();
        this.idEmployee = idEmployee;
        this.idStore = idStore;
    }

    // Lifecycle callbacks
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public Long getIdEmployeeStore() {
        return idEmployeeStore;
    }

    public void setIdEmployeeStore(Long idEmployeeStore) {
        this.idEmployeeStore = idEmployeeStore;
    }

    public Long getIdEmployee() {
        return idEmployee;
    }

    public void setIdEmployee(Long idEmployee) {
        this.idEmployee = idEmployee;
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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        EmployeeStoreJpaEntity that = (EmployeeStoreJpaEntity) o;
        return idEmployeeStore != null && idEmployeeStore.equals(that.idEmployeeStore);
    }

    @Override
    public int hashCode() {
        return idEmployeeStore != null ? idEmployeeStore.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "EmployeeStoreJpaEntity{" +
                "idEmployeeStore=" + idEmployeeStore +
                ", idEmployee=" + idEmployee +
                ", idStore=" + idStore +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
