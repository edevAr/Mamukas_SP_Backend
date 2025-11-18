package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class CompanyRequestDto {

    @NotBlank(message = "El nombre de la empresa no puede estar vacío")
    @Size(max = 255, message = "El nombre no puede exceder 255 caracteres")
    private String name;

    @NotBlank(message = "La dirección no puede estar vacía")
    @Size(max = 500, message = "La dirección no puede exceder 500 caracteres")
    private String address;

    @Pattern(regexp = "^(Opened|Closed)$", message = "El estado debe ser 'Opened' o 'Closed'")
    private String status;

    @Size(max = 255, message = "El horario comercial no puede exceder 255 caracteres")
    private String businessHours;

    // Constructors
    public CompanyRequestDto() {
        this.status = "Opened";
    }

    public CompanyRequestDto(String name, String address, String businessHours) {
        this();
        this.name = name;
        this.address = address;
        this.businessHours = businessHours;
    }

    public CompanyRequestDto(String name, String address, String status, String businessHours) {
        this.name = name;
        this.address = address;
        this.status = status;
        this.businessHours = businessHours;
    }

    // Getters and setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getBusinessHours() {
        return businessHours;
    }

    public void setBusinessHours(String businessHours) {
        this.businessHours = businessHours;
    }
}
