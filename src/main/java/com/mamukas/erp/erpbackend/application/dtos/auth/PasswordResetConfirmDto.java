package com.mamukas.erp.erpbackend.application.dtos.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * DTO for password reset confirmation
 */
public class PasswordResetConfirmDto {
    
    @NotBlank(message = "Token is required")
    private String token;
    
    @NotBlank(message = "New password is required")
    @Size(min = 6, max = 255, message = "Password must be between 6 and 255 characters")
    private String newPassword;
    
    @NotBlank(message = "Password confirmation is required")
    private String confirmPassword;
    
    // Default constructor
    public PasswordResetConfirmDto() {
    }
    
    // Constructor
    public PasswordResetConfirmDto(String token, String newPassword, String confirmPassword) {
        this.token = token;
        this.newPassword = newPassword;
        this.confirmPassword = confirmPassword;
    }
    
    // Getters and Setters
    public String getToken() {
        return token;
    }
    
    public void setToken(String token) {
        this.token = token;
    }
    
    public String getNewPassword() {
        return newPassword;
    }
    
    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }
    
    public String getConfirmPassword() {
        return confirmPassword;
    }
    
    public void setConfirmPassword(String confirmPassword) {
        this.confirmPassword = confirmPassword;
    }
    
    // Validation methods
    public boolean isPasswordsMatch() {
        return newPassword != null && newPassword.equals(confirmPassword);
    }
    
    public void validatePasswordReset() {
        if (!isPasswordsMatch()) {
            throw new IllegalArgumentException("Passwords do not match");
        }
    }
}
