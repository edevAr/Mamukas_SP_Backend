package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.*;

public class ProviderRequestDto {
    
    @NotBlank(message = "El nombre no puede estar vacío")
    @Size(max = 255, message = "El nombre no puede exceder 255 caracteres")
    private String name;
    
    @Pattern(regexp = "^[+]?[0-9\\s\\-()]{7,20}$", message = "El teléfono debe tener un formato válido")
    @Size(max = 20, message = "El teléfono no puede exceder 20 caracteres")
    private String phone;
    
    @Email(message = "El email debe tener un formato válido")
    @Size(max = 255, message = "El email no puede exceder 255 caracteres")
    private String email;
    
    @NotBlank(message = "El NIT o CI no puede estar vacío")
    @Size(max = 50, message = "El NIT o CI no puede exceder 50 caracteres")
    private String nitOrCi;
    
    // Constructors
    public ProviderRequestDto() {}
    
    public ProviderRequestDto(String name, String phone, String email, String nitOrCi) {
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.nitOrCi = nitOrCi;
    }
    
    // Getters and setters
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getNitOrCi() {
        return nitOrCi;
    }
    
    public void setNitOrCi(String nitOrCi) {
        this.nitOrCi = nitOrCi;
    }
}
