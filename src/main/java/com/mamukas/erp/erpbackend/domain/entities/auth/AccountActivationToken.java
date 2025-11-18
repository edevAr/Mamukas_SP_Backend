package com.mamukas.erp.erpbackend.domain.entities.auth;

import java.time.LocalDateTime;

/**
 * Domain entity for account activation tokens
 * Used to manage email verification during user registration
 */
public class AccountActivationToken {
    
    private Long id;
    private String token;
    private String email;
    private Long userId;
    private LocalDateTime expiryDate;
    private boolean used;
    private LocalDateTime createdAt;
    private LocalDateTime usedAt;
    
    // Default constructor
    public AccountActivationToken() {
    }
    
    // Constructor for creation
    public AccountActivationToken(String token, String email, Long userId, LocalDateTime expiryDate) {
        this.token = token;
        this.email = email;
        this.userId = userId;
        this.expiryDate = expiryDate;
        this.used = false;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getToken() {
        return token;
    }
    
    public void setToken(String token) {
        this.token = token;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public Long getUserId() {
        return userId;
    }
    
    public void setUserId(Long userId) {
        this.userId = userId;
    }
    
    public LocalDateTime getExpiryDate() {
        return expiryDate;
    }
    
    public void setExpiryDate(LocalDateTime expiryDate) {
        this.expiryDate = expiryDate;
    }
    
    public boolean isUsed() {
        return used;
    }
    
    public void setUsed(boolean used) {
        this.used = used;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUsedAt() {
        return usedAt;
    }
    
    public void setUsedAt(LocalDateTime usedAt) {
        this.usedAt = usedAt;
    }
    
    // Business methods
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiryDate);
    }
    
    public boolean isValid() {
        return !used && !isExpired();
    }
    
    public void markAsUsed() {
        this.used = true;
        this.usedAt = LocalDateTime.now();
    }
    
    public long getTimeToExpiryInSeconds() {
        if (isExpired()) {
            return 0;
        }
        return java.time.Duration.between(LocalDateTime.now(), expiryDate).getSeconds();
    }
}
