package com.mamukas.erp.erpbackend.infrastructure.persistence.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "refresh_tokens")
public class RefreshTokenJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_refresh_token")
    private Long idRefreshToken;

    @Column(name = "token", unique = true, nullable = false, columnDefinition = "TEXT")
    private String token;

    @Column(name = "id_user", nullable = false)
    private Long idUser;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "revoked", nullable = false)
    private Boolean revoked;

    // Constructors
    public RefreshTokenJpaEntity() {}

    public RefreshTokenJpaEntity(String token, Long idUser, LocalDateTime expiresAt, 
                               LocalDateTime createdAt, Boolean revoked) {
        this.token = token;
        this.idUser = idUser;
        this.expiresAt = expiresAt;
        this.createdAt = createdAt;
        this.revoked = revoked;
    }

    // Getters and setters
    public Long getIdRefreshToken() {
        return idRefreshToken;
    }

    public void setIdRefreshToken(Long idRefreshToken) {
        this.idRefreshToken = idRefreshToken;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Long getIdUser() {
        return idUser;
    }

    public void setIdUser(Long idUser) {
        this.idUser = idUser;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Boolean getRevoked() {
        return revoked;
    }

    public void setRevoked(Boolean revoked) {
        this.revoked = revoked;
    }
}
