package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDateTime;

public class RoleResponseDto {
    private Long idRole;
    private String roleName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public RoleResponseDto() {}

    public RoleResponseDto(Long idRole, String roleName, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idRole = idRole;
        this.roleName = roleName;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
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
