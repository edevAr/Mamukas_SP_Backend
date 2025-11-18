package com.mamukas.erp.erpbackend.application.dtos.auth;

import jakarta.validation.constraints.NotBlank;

/**
 * DTO for refresh token requests
 */
public class RefreshTokenRequestDto {
    
    @NotBlank(message = "Refresh token is required")
    private String refreshToken;
    
    // Default constructor
    public RefreshTokenRequestDto() {
    }
    
    // Constructor
    public RefreshTokenRequestDto(String refreshToken) {
        this.refreshToken = refreshToken;
    }
    
    // Getters and Setters
    public String getRefreshToken() {
        return refreshToken;
    }
    
    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }
}
