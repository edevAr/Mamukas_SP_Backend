package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDateTime;

public class RolePermissionResponseDto {
    private Long idRolePermission;
    private Long idRole;
    private Long idPermission;
    private String roleName;
    private String permissionName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public RolePermissionResponseDto() {}

    public RolePermissionResponseDto(Long idRolePermission, Long idRole, Long idPermission, 
                                   String roleName, String permissionName,
                                   LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idRolePermission = idRolePermission;
        this.idRole = idRole;
        this.idPermission = idPermission;
        this.roleName = roleName;
        this.permissionName = permissionName;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Simplified constructor
    public RolePermissionResponseDto(Long idRolePermission, Long idRole, Long idPermission, 
                                   LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idRolePermission = idRolePermission;
        this.idRole = idRole;
        this.idPermission = idPermission;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
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

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getPermissionName() {
        return permissionName;
    }

    public void setPermissionName(String permissionName) {
        this.permissionName = permissionName;
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
