package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

public class Provider {
    
    private Long idProvider;
    private String name;
    private String phone;
    private String email;
    private String nitOrCi;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public Provider() {}
    
    public Provider(String name, String phone, String email, String nitOrCi) {
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.nitOrCi = nitOrCi;
    }
    
    public Provider(Long idProvider, String name, String phone, String email, String nitOrCi, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idProvider = idProvider;
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.nitOrCi = nitOrCi;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Business methods
    public boolean hasValidName() {
        return name != null && !name.trim().isEmpty() && name.length() <= 255;
    }
    
    public boolean hasValidEmail() {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        return email.contains("@") && email.contains(".");
    }
    
    public boolean hasValidPhone() {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        return phone.matches("^[+]?[0-9\\s\\-()]{7,20}$");
    }
    
    public boolean hasValidNitOrCi() {
        return nitOrCi != null && !nitOrCi.trim().isEmpty() && nitOrCi.length() <= 50;
    }
    
    public boolean isValidProvider() {
        return hasValidName() && hasValidNitOrCi() && 
               (phone == null || hasValidPhone()) && 
               (email == null || hasValidEmail());
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
    
    @Override
    public String toString() {
        return "Provider{" +
                "idProvider=" + idProvider +
                ", name='" + name + '\'' +
                ", phone='" + phone + '\'' +
                ", email='" + email + '\'' +
                ", nitOrCi='" + nitOrCi + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
