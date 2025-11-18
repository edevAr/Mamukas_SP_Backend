package com.mamukas.erp.erpbackend.application.dtos.user;

import jakarta.validation.constraints.*;

/**
 * Unified DTO for user requests (both create and update operations)
 * For updates, all fields are optional except where business logic requires them
 * For creates, required fields are marked with validation annotations
 */
public class UserRequestDto {
    
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "Username can only contain letters, numbers and underscore")
    private String username;
    
    @Email(message = "Email format is invalid")
    @Size(max = 100, message = "Email must not exceed 100 characters")
    private String email;
    
    @Size(min = 6, max = 255, message = "Password must be between 6 and 255 characters")
    private String password;
    
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    @Pattern(regexp = "^[a-zA-ZáéíóúÁÉÍÓÚñÑ\\s]+$", message = "Name can only contain letters and spaces")
    private String name;
    
    @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
    @Pattern(regexp = "^[a-zA-ZáéíóúÁÉÍÓÚñÑ\\s]+$", message = "Last name can only contain letters and spaces")
    private String lastName;
    
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 120, message = "Age must not exceed 120")
    private Integer age;
    
    @Size(min = 7, max = 15, message = "CI must be between 7 and 15 characters")
    @Pattern(regexp = "^[0-9]+$", message = "CI can only contain numbers")
    private String ci;
    
    @Min(value = 0, message = "Status must be 0 (Pending), 1 (Active), or 2 (Inactive)")
    @Max(value = 2, message = "Status must be 0 (Pending), 1 (Active), or 2 (Inactive)")
    private Integer status; // 0: Pendiente activación, 1: Activo, 2: Inactivo
    
    @Size(min = 2, max = 50, message = "Role name must be between 2 and 50 characters")
    private String roleName;
    
    // Default constructor
    public UserRequestDto() {
    }
    
    // Constructor with all fields
    public UserRequestDto(String username, String email, String password, String name, 
                         String lastName, Integer age, String ci, Integer status, String roleName) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.name = name;
        this.lastName = lastName;
        this.age = age;
        this.ci = ci;
        this.status = status;
        this.roleName = roleName;
    }
    
    // Getters and Setters
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
    
    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
    
    // Utility methods
    
    /**
     * Check if this is a valid create request (has all required fields)
     * @return true if all required fields are present
     */
    public boolean isValidForCreation() {
        return username != null && !username.trim().isEmpty() &&
               email != null && !email.trim().isEmpty() &&
               password != null && !password.trim().isEmpty() &&
               name != null && !name.trim().isEmpty() &&
               lastName != null && !lastName.trim().isEmpty() &&
               age != null &&
               ci != null && !ci.trim().isEmpty();
    }
    
    /**
     * Check if this is a valid update request (has at least one field to update)
     * @return true if at least one field is present for update
     */
    public boolean isValidForUpdate() {
        return username != null || email != null || password != null || 
               name != null || lastName != null || age != null || 
               ci != null || status != null;
    }
    
    /**
     * Validate required fields for creation
     * @throws IllegalArgumentException if validation fails
     */
    public void validateForCreation() {
        if (!isValidForCreation()) {
            throw new IllegalArgumentException("Missing required fields for user creation");
        }
    }
    
    /**
     * Validate that at least one field is present for update
     * @throws IllegalArgumentException if no fields are provided
     */
    public void validateForUpdate() {
        if (!isValidForUpdate()) {
            throw new IllegalArgumentException("At least one field must be provided for update");
        }
    }
}
