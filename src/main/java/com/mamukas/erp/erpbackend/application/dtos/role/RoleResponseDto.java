package com.mamukas.erp.erpbackend.application.dtos.role;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

/**
 * DTO for role response data
 */
public class RoleResponseDto {
    
    @JsonProperty("idRole")
    private Long idRole;
    
    @JsonProperty("roleName")
    private String roleName;
    
    @JsonProperty("createdAt")
    private LocalDateTime createdAt;
    
    @JsonProperty("updatedAt")
    private LocalDateTime updatedAt;
    
    // Default constructor
    public RoleResponseDto() {}
    
    // Constructor with parameters
    public RoleResponseDto(Long idRole, String roleName, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idRole = idRole;
        this.roleName = roleName;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and setters
    public Long getIdRole() {
        return idRole;
    }
    
    public void setIdRole(Long idRole) {
        this.idRole = idRole;
    }
    
    public String getRoleName() {
        return roleName;
    }
    
    public void setRoleName(String roleName) {
        this.roleName = roleName;
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
    
    @Override
    public String toString() {
        return "RoleResponseDto{" +
                "idRole=" + idRole +
                ", roleName='" + roleName + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
