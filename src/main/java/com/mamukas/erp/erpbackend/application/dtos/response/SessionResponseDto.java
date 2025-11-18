package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDateTime;

public class SessionResponseDto {
    
    private Long idSession;
    private String status;
    private LocalDateTime dateLogin;
    private LocalDateTime dateLogout;
    private String device;
    private String ip;
    private Long idUser;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public SessionResponseDto() {}
    
    public SessionResponseDto(Long idSession, String status, LocalDateTime dateLogin, 
                             LocalDateTime dateLogout, String device, String ip, Long idUser,
                             LocalDateTime createdAt, LocalDateTime updatedAt) {
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
    }
    
    public LocalDateTime getDateLogin() {
        return dateLogin;
    }
    
    public void setDateLogin(LocalDateTime dateLogin) {
        this.dateLogin = dateLogin;
    }
    
    public LocalDateTime getDateLogout() {
        return dateLogout;
    }
    
    public void setDateLogout(LocalDateTime dateLogout) {
        this.dateLogout = dateLogout;
    }
    
    public String getDevice() {
        return device;
    }
    
    public void setDevice(String device) {
        this.device = device;
    }
    
    public String getIp() {
        return ip;
    }
    
    public void setIp(String ip) {
        this.ip = ip;
    }
    
    public Long getIdUser() {
        return idUser;
    }
    
    public void setIdUser(Long idUser) {
        this.idUser = idUser;
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
