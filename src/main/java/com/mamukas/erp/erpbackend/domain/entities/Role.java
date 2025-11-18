package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

/**
 * Domain entity representing a role in the system
 */
public class Role {
    private Long idRole;
    private String roleName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Default constructor
    public Role() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor without ID (for creation)
    public Role(String roleName) {
        this();
        this.roleName = roleName;
    }

    // Constructor with ID (for updates)
    public Role(Long idRole, String roleName) {
        this(roleName);
        this.idRole = idRole;
    }

    // Full constructor
    public Role(Long idRole, String roleName, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idRole = idRole;
        this.roleName = roleName;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Business methods
    public void updateRoleName(String newRoleName) {
        if (newRoleName == null || newRoleName.trim().isEmpty()) {
            throw new IllegalArgumentException("Role name cannot be null or empty");
        }
        this.roleName = newRoleName.trim();
        this.updatedAt = LocalDateTime.now();
    }

    public boolean isValidRole() {
        return roleName != null && !roleName.trim().isEmpty();
    }

    // Getters and setters
    public Long getIdRole() {
        return idRole;
    }

    public void setIdRole(Long idRole) {
        this.idRole = idRole;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
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
        Role role = (Role) o;
        return idRole != null && idRole.equals(role.idRole);
    }

    @Override
    public int hashCode() {
        return idRole != null ? idRole.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "Role{" +
                "idRole=" + idRole +
                ", roleName='" + roleName + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
