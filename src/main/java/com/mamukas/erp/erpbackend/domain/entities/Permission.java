package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

/**
 * Domain entity representing a permission in the system
 */
public class Permission {
    private Long idPermission;
    private String name;
    private Boolean status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Default constructor
    public Permission() {
        this.status = true; // Active by default
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor without ID (for creation)
    public Permission(String name) {
        this();
        this.name = name;
    }

    // Constructor with status
    public Permission(String name, Boolean status) {
        this(name);
        this.status = status;
    }

    // Constructor with ID (for updates)
    public Permission(Long idPermission, String name, Boolean status) {
        this(name, status);
        this.idPermission = idPermission;
    }

    // Full constructor
    public Permission(Long idPermission, String name, Boolean status, 
                     LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idPermission = idPermission;
        this.name = name;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Business methods
    public void activate() {
        this.status = true;
        this.updatedAt = LocalDateTime.now();
    }

    public void deactivate() {
        this.status = false;
        this.updatedAt = LocalDateTime.now();
    }

    public void updateName(String newName) {
        if (newName == null || newName.trim().isEmpty()) {
            throw new IllegalArgumentException("Permission name cannot be null or empty");
        }
        this.name = newName.trim();
        this.updatedAt = LocalDateTime.now();
    }

    public boolean isActive() {
        return status != null && status;
    }

    public boolean isValidPermission() {
        return name != null && !name.trim().isEmpty();
    }

    // Getters and setters
    public Long getIdPermission() {
        return idPermission;
    }

    public void setIdPermission(Long idPermission) {
        this.idPermission = idPermission;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
        this.updatedAt = LocalDateTime.now();
    }

    public Boolean getStatus() {
        return status;
    }

    public void setStatus(Boolean status) {
        this.status = status;
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
        Permission permission = (Permission) o;
        return idPermission != null && idPermission.equals(permission.idPermission);
    }

    @Override
    public int hashCode() {
        return idPermission != null ? idPermission.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "Permission{" +
                "idPermission=" + idPermission +
                ", name='" + name + '\'' +
                ", status=" + status +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
