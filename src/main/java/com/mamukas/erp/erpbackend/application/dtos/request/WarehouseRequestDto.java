package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class WarehouseRequestDto {
    
    @NotBlank(message = "La dirección no puede estar vacía")
    @Size(max = 255, message = "La dirección no puede exceder 255 caracteres")
    private String address;
    
    @Pattern(regexp = "^(Active|Inactive)$", message = "El estado debe ser 'Active' o 'Inactive'")
    private String status = "Active";
    
    // Constructors
    public WarehouseRequestDto() {}
    
    public WarehouseRequestDto(String address, String status) {
        this.address = address;
        this.status = status;
    }
    
    // Getters and setters
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
}
