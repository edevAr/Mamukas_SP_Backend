package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class RoleRequestDto {

    @NotBlank(message = "El nombre del rol no puede estar vacío")
    @Size(min = 2, max = 100, message = "El nombre del rol debe tener entre 2 y 100 caracteres")
    private String roleName;

    // Constructors
    public RoleRequestDto() {}

    public RoleRequestDto(String roleName) {
        this.roleName = roleName;
    }

    // Getters and setters
    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
}
