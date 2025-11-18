package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDateTime;

public class ProviderResponseDto {
    
    private Long idProvider;
    private String name;
    private String phone;
    private String email;
    private String nitOrCi;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public ProviderResponseDto() {}
    
    public ProviderResponseDto(Long idProvider, String name, String phone, String email, String nitOrCi, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idProvider = idProvider;
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.nitOrCi = nitOrCi;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and setters
    public Long getIdProvider() {
        return idProvider;
    }
    
    public void setIdProvider(Long idProvider) {
        this.idProvider = idProvider;
    }
    
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
