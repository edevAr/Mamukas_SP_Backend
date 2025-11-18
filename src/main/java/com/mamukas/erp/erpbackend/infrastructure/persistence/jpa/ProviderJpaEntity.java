package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "providers")
public class ProviderJpaEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_provider")
    private Long idProvider;
    
    @Column(name = "name", nullable = false, length = 255)
    private String name;
    
    @Column(name = "phone", length = 20)
    private String phone;
    
    @Column(name = "email", length = 255)
    private String email;
    
    @Column(name = "nit_or_ci", nullable = false, length = 50, unique = true)
    private String nitOrCi;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public ProviderJpaEntity() {}
    
    public ProviderJpaEntity(String name, String phone, String email, String nitOrCi) {
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.nitOrCi = nitOrCi;
    }
    
    public ProviderJpaEntity(Long idProvider, String name, String phone, String email, String nitOrCi, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idProvider = idProvider;
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.nitOrCi = nitOrCi;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters and setters
    public Long getIdProvider() {
        return idProvider;
    }
    
    public void setIdProvider(Long idProvider) {
        this.idProvider = idProvider;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getNitOrCi() {
        return nitOrCi;
    }
    
    public void setNitOrCi(String nitOrCi) {
        this.nitOrCi = nitOrCi;
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
