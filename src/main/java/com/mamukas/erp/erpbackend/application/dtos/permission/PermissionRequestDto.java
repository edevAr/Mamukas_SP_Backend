package com.mamukas.erp.erpbackend.application.dtos.permission;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * DTO for permission creation and update requests
 */
public class PermissionRequestDto {
    
    @NotBlank(message = "Permission name is required")
    @Size(min = 2, max = 100, message = "Permission name must be between 2 and 100 characters")
    @JsonProperty("name")
    private String name;
    
    @NotNull(message = "Status is required")
    @JsonProperty("status")
    private Boolean status;
    
    // Default constructor
    public PermissionRequestDto() {}
    
    // Constructor with parameters
    public PermissionRequestDto(String name, Boolean status) {
        this.name = name;
        this.status = status;
    }
    
    // Getters and setters
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
    
    @Override
    public String toString() {
        return "PermissionRequestDto{" +
                "name='" + name + '\'' +
                ", status=" + status +
                '}';
    }
}
