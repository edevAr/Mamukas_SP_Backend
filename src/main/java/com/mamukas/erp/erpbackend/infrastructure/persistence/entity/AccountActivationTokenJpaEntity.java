package com.mamukas.erp.erpbackend.infrastructure.persistence.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "account_activation_tokens")
public class AccountActivationTokenJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_activation_token")
    private Long idActivationToken;

    @Column(name = "token", unique = true, nullable = false, length = 255)
    private String token;

    @Column(name = "email", nullable = false, length = 255)
    private String email;

    @Column(name = "used", nullable = false)
    private Boolean used;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "used_at")
    private LocalDateTime usedAt;

    // Constructors
    public AccountActivationTokenJpaEntity() {}

    public AccountActivationTokenJpaEntity(String token, String email, Boolean used, 
                                         LocalDateTime createdAt, LocalDateTime expiresAt) {
        this.token = token;
        this.email = email;
        this.used = used;
        this.createdAt = createdAt;
        this.expiresAt = expiresAt;
    }

    // Getters and setters
    public Long getIdActivationToken() {
        return idActivationToken;
    }

    public void setIdActivationToken(Long idActivationToken) {
        this.idActivationToken = idActivationToken;
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

    public Boolean getUsed() {
        return used;
    }

    public void setUsed(Boolean used) {
        this.used = used;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public LocalDateTime getUsedAt() {
        return usedAt;
    }

    public void setUsedAt(LocalDateTime usedAt) {
        this.usedAt = usedAt;
    }
}
