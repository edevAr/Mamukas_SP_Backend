package com.mamukas.erp.erpbackend.application.dtos.role;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * DTO for role creation and update requests
 */
public class RoleRequestDto {
    
    @NotBlank(message = "Role name is required")
    @Size(min = 2, max = 50, message = "Role name must be between 2 and 50 characters")
    @JsonProperty("roleName")
    private String roleName;
    
    // Default constructor
    public RoleRequestDto() {}
    
    // Constructor with parameters
    public RoleRequestDto(String roleName) {
        this.roleName = roleName;
    }
    
    // Getters and setters
    public String getRoleName() {
        return roleName;
    }
    
    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
    
    @Override
    public String toString() {
        return "RoleRequestDto{" +
                "roleName='" + roleName + '\'' +
                '}';
    }
}
