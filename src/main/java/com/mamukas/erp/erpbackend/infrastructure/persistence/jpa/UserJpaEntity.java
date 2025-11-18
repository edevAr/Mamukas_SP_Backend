package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

/**
 * JPA Entity for User table
 * This entity is specific to the infrastructure layer and handles database mapping
 */
@Entity
@Table(name = "users", uniqueConstraints = {
    @UniqueConstraint(columnNames = "username"),
    @UniqueConstraint(columnNames = "email"),
    @UniqueConstraint(columnNames = "ci")
})
public class UserJpaEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_user")
    private Long idUser;
    
    @Column(name = "username", nullable = false, length = 50)
    private String username;
    
    @Column(name = "email", nullable = false, length = 100)
    private String email;
    
    @Column(name = "password", nullable = false)
    private String password;
    
    @Column(name = "name", nullable = false, length = 50)
    private String name;
    
    @Column(name = "last_name", nullable = false, length = 50)
    private String lastName;
    
    @Column(name = "age", nullable = false)
    private Integer age;
    
    @Column(name = "ci", nullable = false, length = 15)
    private String ci;
    
    @Column(name = "status", nullable = false)
    private Integer status; // 0: Pendiente activación, 1: Activo, 2: Inactivo
    
    @Column(name = "email_verified", nullable = false)
    private Boolean emailVerified = false;
    
    @Column(name = "role_id")
    private Long roleId;
    
    @Column(name = "created_at", updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private java.util.Date createdAt;
    
    @Column(name = "updated_at")
    @Temporal(TemporalType.TIMESTAMP)
    private java.util.Date updatedAt;
    
    // Default constructor
    public UserJpaEntity() {
    }
    
    // Constructor with all fields except ID and timestamps
    public UserJpaEntity(String username, String email, String password, String name, 
                        String lastName, Integer age, String ci, Integer status) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.name = name;
        this.lastName = lastName;
        this.age = age;
        this.ci = ci;
        this.status = status;
        this.emailVerified = false; // Por defecto no verificado
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = new java.util.Date();
        updatedAt = new java.util.Date();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = new java.util.Date();
    }
    
    // Getters and Setters
    public Long getIdUser() {
        return idUser;
    }
    
    public void setIdUser(Long idUser) {
        this.idUser = idUser;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getLastName() {
        return lastName;
    }
    
    public void setLastName(String lastName) {
        this.lastName = lastName;
    }
    
    public Integer getAge() {
        return age;
    }
    
    public void setAge(Integer age) {
        this.age = age;
    }
    
    public String getCi() {
        return ci;
    }
    
    public void setCi(String ci) {
        this.ci = ci;
    }
    
    public Integer getStatus() {
        return status;
    }
    
    public void setStatus(Integer status) {
        this.status = status;
    }
    
    public java.util.Date getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(java.util.Date createdAt) {
        this.createdAt = createdAt;
    }
    
    public java.util.Date getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(java.util.Date updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public Boolean getEmailVerified() {
        return emailVerified;
    }
    
    public void setEmailVerified(Boolean emailVerified) {
        this.emailVerified = emailVerified;
    }
    
    public Long getRoleId() {
        return roleId;
    }

    public void setRoleId(Long roleId) {
        this.roleId = roleId;
    }
}
