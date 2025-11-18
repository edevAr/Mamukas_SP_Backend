package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.*;

public class CustomerRequestDto {
    
    @NotBlank(message = "El nombre no puede estar vacío")
    @Size(max = 255, message = "El nombre no puede exceder 255 caracteres")
    private String name;
    
    @NotBlank(message = "El NIT no puede estar vacío")
    @Size(max = 50, message = "El NIT no puede exceder 50 caracteres")
    private String nit;
    
    // Constructors
    public CustomerRequestDto() {}
    
    public CustomerRequestDto(String name, String nit) {
        this.name = name;
        this.nit = nit;
    }
    
    // Getters and setters
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getNit() {
        return nit;
    }
    
    public void setNit(String nit) {
        this.nit = nit;
    }
}
