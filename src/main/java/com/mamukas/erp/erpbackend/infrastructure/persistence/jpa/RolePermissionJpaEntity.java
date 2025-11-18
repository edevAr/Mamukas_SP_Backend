package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "role_permissions")
public class RolePermissionJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_role_permission")
    private Long idRolePermission;

    @Column(name = "id_role", nullable = false)
    private Long idRole;

    @Column(name = "id_permission", nullable = false)
    private Long idPermission;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public RolePermissionJpaEntity() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor for creation
    public RolePermissionJpaEntity(Long idRole, Long idPermission) {
        this();
        this.idRole = idRole;
        this.idPermission = idPermission;
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
    }

    public Long getIdPermission() {
        return idPermission;
    }

    public void setIdPermission(Long idPermission) {
        this.idPermission = idPermission;
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
        RolePermissionJpaEntity that = (RolePermissionJpaEntity) o;
        return idRolePermission != null && idRolePermission.equals(that.idRolePermission);
    }

    @Override
    public int hashCode() {
        return idRolePermission != null ? idRolePermission.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "RolePermissionJpaEntity{" +
                "idRolePermission=" + idRolePermission +
                ", idRole=" + idRole +
                ", idPermission=" + idPermission +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
