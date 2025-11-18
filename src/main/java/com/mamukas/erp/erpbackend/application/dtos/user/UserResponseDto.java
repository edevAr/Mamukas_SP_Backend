package com.mamukas.erp.erpbackend.application.dtos.user;

/**
 * DTO for user response data
 * Used to return user information without sensitive data like password
 */
public class UserResponseDto {
    
    private Long idUser;
    private String username;
    private String email;
    private String name;
    private String lastName;
    private Integer age;
    private String ci;
    private Integer status; // 0: Pendiente activación, 1: Activo, 2: Inactivo
    private String fullName;
    private String roleName;
    
    // Default constructor
    public UserResponseDto() {
    }
    
    // Constructor with all fields
    public UserResponseDto(Long idUser, String username, String email, String name, 
                          String lastName, Integer age, String ci, Integer status, String roleName) {
        this.idUser = idUser;
        this.username = username;
        this.email = email;
        this.name = name;
        this.lastName = lastName;
        this.age = age;
        this.ci = ci;
        this.status = status;
        this.roleName = roleName;
        this.fullName = (name != null ? name : "") + " " + (lastName != null ? lastName : "");
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
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
        updateFullName();
    }
    
    public String getLastName() {
        return lastName;
    }
    
    public void setLastName(String lastName) {
        this.lastName = lastName;
        updateFullName();
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
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
    
    // Utility methods
    public boolean isActive() {
        return status != null && status == 1; // 1 = Activo
    }
    
    public boolean isPending() {
        return status != null && status == 0; // 0 = Pendiente activación
    }
    
    public boolean isInactive() {
        return status != null && status == 2; // 2 = Inactivo
    }
    
    private void updateFullName() {
        this.fullName = (name != null ? name : "") + " " + (lastName != null ? lastName : "");
    }
}
