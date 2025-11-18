package com.mamukas.erp.erpbackend.application.dtos.auth;

import jakarta.validation.constraints.*;

/**
 * DTO for user registration requests
 * Inherits validation from UserRequestDto but adds specific registration rules
 */
public class RegisterRequestDto {
    
    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "Username can only contain letters, numbers and underscore")
    private String username;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email format is invalid")
    @Size(max = 100, message = "Email must not exceed 100 characters")
    private String email;
    
    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 255, message = "Password must be between 6 and 255 characters")
    private String password;
    
    @NotBlank(message = "Password confirmation is required")
    private String confirmPassword;
    
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    @Pattern(regexp = "^[a-zA-ZáéíóúÁÉÍÓÚñÑ\\s]+$", message = "Name can only contain letters and spaces")
    private String name;
    
    @NotBlank(message = "Last name is required")
    @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
    @Pattern(regexp = "^[a-zA-ZáéíóúÁÉÍÓÚñÑ\\s]+$", message = "Last name can only contain letters and spaces")
    private String lastName;
    
    @NotNull(message = "Age is required")
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 120, message = "Age must not exceed 120")
    private Integer age;
    
    @NotBlank(message = "CI is required")
    @Size(min = 7, max = 15, message = "CI must be between 7 and 15 characters")
    @Pattern(regexp = "^[0-9]+$", message = "CI can only contain numbers")
    private String ci;
    
    private boolean acceptTerms = false;
    
    // Default constructor
    public RegisterRequestDto() {
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
    
    public String getConfirmPassword() {
        return confirmPassword;
    }
    
    public void setConfirmPassword(String confirmPassword) {
        this.confirmPassword = confirmPassword;
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
    
    public boolean isAcceptTerms() {
        return acceptTerms;
    }
    
    public void setAcceptTerms(boolean acceptTerms) {
        this.acceptTerms = acceptTerms;
    }
    
    // Validation methods
    public boolean isPasswordsMatch() {
        return password != null && password.equals(confirmPassword);
    }
    
    public void validateRegistration() {
        if (!isPasswordsMatch()) {
            throw new IllegalArgumentException("Passwords do not match");
        }
        
        if (!acceptTerms) {
            throw new IllegalArgumentException("You must accept the terms and conditions");
        }
    }
}
