package com.mamukas.erp.erpbackend.application.dtos.permission;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

/**
 * DTO for permission response data
 */
public class PermissionResponseDto {
    
    @JsonProperty("idPermission")
    private Long idPermission;
    
    @JsonProperty("name")
    private String name;
    
    @JsonProperty("status")
    private Boolean status;
    
    @JsonProperty("createdAt")
    private LocalDateTime createdAt;
    
    @JsonProperty("updatedAt")
    private LocalDateTime updatedAt;
    
    // Default constructor
    public PermissionResponseDto() {}
    
    // Constructor with parameters
    public PermissionResponseDto(Long idPermission, String name, Boolean status, 
                                LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idPermission = idPermission;
        this.name = name;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and setters
    public Long getIdPermission() {
        return idPermission;
    }
    
    public void setIdPermission(Long idPermission) {
        this.idPermission = idPermission;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public Boolean getStatus() {
        return status;
    }
    
    public void setStatus(Boolean status) {
        this.status = status;
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
        return "PermissionResponseDto{" +
                "idPermission=" + idPermission +
                ", name='" + name + '\'' +
                ", status=" + status +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
