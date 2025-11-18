package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Session JPA entity for database persistence
 */
@Entity
@Table(name = "sessions")
public class SessionJpaEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_session")
    private Long idSession;
    
    @Column(name = "status", nullable = false, length = 20)
    private String status;
    
    @Column(name = "date_login", nullable = false)
    private LocalDateTime dateLogin;
    
    @Column(name = "date_logout")
    private LocalDateTime dateLogout;
    
    @Column(name = "device", length = 100)
    private String device;
    
    @Column(name = "ip", length = 45)
    private String ip;
    
    @Column(name = "id_user", nullable = false)
    private Long idUser;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    // Constructors
    public SessionJpaEntity() {}
    
    public SessionJpaEntity(String status, LocalDateTime dateLogin, LocalDateTime dateLogout,
                           String device, String ip, Long idUser, LocalDateTime createdAt, 
                           LocalDateTime updatedAt) {
        this.status = status;
        this.dateLogin = dateLogin;
        this.dateLogout = dateLogout;
        this.device = device;
        this.ip = ip;
        this.idUser = idUser;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // JPA lifecycle methods
    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
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
