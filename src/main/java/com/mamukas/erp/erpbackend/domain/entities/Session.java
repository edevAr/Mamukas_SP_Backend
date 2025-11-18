package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

/**
 * Session domain entity representing user session information
 */
public class Session {
    
    private Long idSession;
    private String status; // Active, Inactive
    private LocalDateTime dateLogin;
    private LocalDateTime dateLogout;
    private String device;
    private String ip;
    private Long idUser; // Foreign key to User
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public Session() {}
    
    public Session(String status, LocalDateTime dateLogin, String device, String ip, Long idUser) {
        this.status = status;
        this.dateLogin = dateLogin;
        this.device = device;
        this.ip = ip;
        this.idUser = idUser;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    public Session(Long idSession, String status, LocalDateTime dateLogin, LocalDateTime dateLogout, 
                  String device, String ip, Long idUser, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idSession = idSession;
        this.status = status;
        this.dateLogin = dateLogin;
        this.dateLogout = dateLogout;
        this.device = device;
        this.ip = ip;
        this.idUser = idUser;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Business methods
    public void activate() {
        this.status = "Active";
        this.updatedAt = LocalDateTime.now();
    }
    
    public void deactivate() {
        this.status = "Inactive";
        this.dateLogout = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    public boolean isActive() {
        return "Active".equals(this.status);
    }
    
    public boolean isInactive() {
        return "Inactive".equals(this.status);
    }
    
    // Getters and setters
    public Long getIdSession() {
        return idSession;
    }
    
    public void setIdSession(Long idSession) {
        this.idSession = idSession;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();
    }
    
    public LocalDateTime getDateLogin() {
        return dateLogin;
    }
    
    public void setDateLogin(LocalDateTime dateLogin) {
        this.dateLogin = dateLogin;
        this.updatedAt = LocalDateTime.now();
    }
    
    public LocalDateTime getDateLogout() {
        return dateLogout;
    }
    
    public void setDateLogout(LocalDateTime dateLogout) {
        this.dateLogout = dateLogout;
        this.updatedAt = LocalDateTime.now();
    }
    
    public String getDevice() {
        return device;
    }
    
    public void setDevice(String device) {
        this.device = device;
        this.updatedAt = LocalDateTime.now();
    }
    
    public String getIp() {
        return ip;
    }
    
    public void setIp(String ip) {
        this.ip = ip;
        this.updatedAt = LocalDateTime.now();
    }
    
    public Long getIdUser() {
        return idUser;
    }
    
    public void setIdUser(Long idUser) {
        this.idUser = idUser;
        this.updatedAt = LocalDateTime.now();
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
