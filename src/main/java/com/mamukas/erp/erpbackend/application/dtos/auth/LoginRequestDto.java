package com.mamukas.erp.erpbackend.application.dtos.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * DTO for user login requests
 */
public class LoginRequestDto {
    
    @NotBlank(message = "Username or email is required")
    private String usernameOrEmail;
    
    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;
    
    private boolean rememberMe = false;
    
    // Default constructor
    public LoginRequestDto() {
    }
    
    // Constructor
    public LoginRequestDto(String usernameOrEmail, String password, boolean rememberMe) {
        this.usernameOrEmail = usernameOrEmail;
        this.password = password;
        this.rememberMe = rememberMe;
    }
    
    // Getters and Setters
    public String getUsernameOrEmail() {
        return usernameOrEmail;
    }
    
    public void setUsernameOrEmail(String usernameOrEmail) {
        this.usernameOrEmail = usernameOrEmail;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public boolean isRememberMe() {
        return rememberMe;
    }
    
    public void setRememberMe(boolean rememberMe) {
        this.rememberMe = rememberMe;
    }
}
