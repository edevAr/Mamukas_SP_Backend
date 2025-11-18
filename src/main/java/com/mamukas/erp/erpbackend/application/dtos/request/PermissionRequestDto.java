package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class PermissionRequestDto {

    @NotBlank(message = "El nombre del permiso no puede estar vacío")
    @Size(min = 2, max = 100, message = "El nombre del permiso debe tener entre 2 y 100 caracteres")
    private String name;

    private Boolean status = true;

    // Constructors
    public PermissionRequestDto() {}

    public PermissionRequestDto(String name) {
        this.name = name;
    }

    public PermissionRequestDto(String name, Boolean status) {
        this.name = name;
        this.status = status;
    }

    // Getters and setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Boolean getStatus() {
        return status;
    }

    public void setStatus(Boolean status) {
        this.status = status;
    }
}
