package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

/**
 * Domain entity representing the relationship between employees and stores
 */
public class EmployeeStore {
    private Long idEmployeeStore;
    private Long idEmployee;
    private Long idStore;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Default constructor
    public EmployeeStore() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor for creation
    public EmployeeStore(Long idEmployee, Long idStore) {
        this();
        this.idEmployee = idEmployee;
        this.idStore = idStore;
    }

    // Constructor with ID
    public EmployeeStore(Long idEmployeeStore, Long idEmployee, Long idStore) {
        this(idEmployee, idStore);
        this.idEmployeeStore = idEmployeeStore;
    }

    // Full constructor
    public EmployeeStore(Long idEmployeeStore, Long idEmployee, Long idStore, 
                        LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idEmployeeStore = idEmployeeStore;
        this.idEmployee = idEmployee;
        this.idStore = idStore;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Business methods
    public boolean isValidRelationship() {
        return idEmployee != null && idStore != null;
    }

    public void updateTimestamp() {
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
        this.updatedAt = LocalDateTime.now();
    }

    public Long getIdStore() {
        return idStore;
    }

    public void setIdStore(Long idStore) {
        this.idStore = idStore;
        this.updatedAt = LocalDateTime.now();
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
        EmployeeStore that = (EmployeeStore) o;
        return idEmployeeStore != null && idEmployeeStore.equals(that.idEmployeeStore);
    }

    @Override
    public int hashCode() {
        return idEmployeeStore != null ? idEmployeeStore.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "EmployeeStore{" +
                "idEmployeeStore=" + idEmployeeStore +
                ", idEmployee=" + idEmployee +
                ", idStore=" + idStore +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
