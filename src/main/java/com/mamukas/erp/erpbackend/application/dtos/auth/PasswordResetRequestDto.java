package com.mamukas.erp.erpbackend.application.dtos.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/**
 * DTO for password reset requests
 */
public class PasswordResetRequestDto {
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email format is invalid")
    private String email;
    
    // Default constructor
    public PasswordResetRequestDto() {
    }
    
    // Constructor
    public PasswordResetRequestDto(String email) {
        this.email = email;
    }
    
    // Getters and Setters
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
}
