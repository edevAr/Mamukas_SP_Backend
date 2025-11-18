package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

/**
 * Domain entity representing the relationship between roles and permissions
 */
public class RolePermission {
    private Long idRolePermission;
    private Long idRole;
    private Long idPermission;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Default constructor
    public RolePermission() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor for creation
    public RolePermission(Long idRole, Long idPermission) {
        this();
        this.idRole = idRole;
        this.idPermission = idPermission;
    }

    // Constructor with ID
    public RolePermission(Long idRolePermission, Long idRole, Long idPermission) {
        this(idRole, idPermission);
        this.idRolePermission = idRolePermission;
    }

    // Full constructor
    public RolePermission(Long idRolePermission, Long idRole, Long idPermission, 
                         LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idRolePermission = idRolePermission;
        this.idRole = idRole;
        this.idPermission = idPermission;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Business methods
    public boolean isValidRelationship() {
        return idRole != null && idPermission != null;
    }

    public void updateTimestamp() {
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public Long getIdRolePermission() {
        return idRolePermission;
    }

    public void setIdRolePermission(Long idRolePermission) {
        this.idRolePermission = idRolePermission;
    }

    public Long getIdRole() {
        return idRole;
    }

    public void setIdRole(Long idRole) {
        this.idRole = idRole;
        this.updatedAt = LocalDateTime.now();
    }

    public Long getIdPermission() {
        return idPermission;
    }

    public void setIdPermission(Long idPermission) {
        this.idPermission = idPermission;
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
        RolePermission that = (RolePermission) o;
        return idRolePermission != null && idRolePermission.equals(that.idRolePermission);
    }

    @Override
    public int hashCode() {
        return idRolePermission != null ? idRolePermission.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "RolePermission{" +
                "idRolePermission=" + idRolePermission +
                ", idRole=" + idRole +
                ", idPermission=" + idPermission +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
