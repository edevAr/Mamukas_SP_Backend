package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class StoreRequestDto {
    
    @NotBlank(message = "El nombre no puede estar vacío")
    @Size(max = 255, message = "El nombre no puede exceder 255 caracteres")
    private String name;
    
    @NotBlank(message = "La dirección no puede estar vacía")
    @Size(max = 255, message = "La dirección no puede exceder 255 caracteres")
    private String address;
    
    @Pattern(regexp = "^(Open|Close)$", message = "El estado debe ser 'Open' o 'Close'")
    private String status = "Open";
    
    @NotBlank(message = "Los horarios de negocio no pueden estar vacíos")
    @Size(max = 255, message = "Los horarios de negocio no pueden exceder 255 caracteres")
    private String businessHours;
    
    private Long idCompany;
    
    // Constructors
    public StoreRequestDto() {}
    
    public StoreRequestDto(String name, String address, String status, String businessHours, Long idCompany) {
        this.name = name;
        this.address = address;
        this.status = status;
        this.businessHours = businessHours;
        this.idCompany = idCompany;
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
    
    public Long getIdCompany() {
        return idCompany;
    }
    
    public void setIdCompany(Long idCompany) {
        this.idCompany = idCompany;
    }
}
