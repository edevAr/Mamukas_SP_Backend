package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotNull;

public class RolePermissionRequestDto {

    @NotNull(message = "El ID del rol no puede ser nulo")
    private Long idRole;

    @NotNull(message = "El ID del permiso no puede ser nulo")
    private Long idPermission;

    // Constructors
    public RolePermissionRequestDto() {}

    public RolePermissionRequestDto(Long idRole, Long idPermission) {
        this.idRole = idRole;
        this.idPermission = idPermission;
    }

    // Getters and setters
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
}
