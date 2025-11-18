package com.mamukas.erp.erpbackend.domain.entities;

/**
 * User domain entity representing a user in the system
 * This is a plain Java object without any framework dependencies
 */
public class User {
    
    private Long idUser;
    private String username;
    private String email;
    private String password;
    private String name;
    private String lastName;
    private Integer age;
    private String ci;
    private Integer status; // 0: Pendiente activación, 1: Activo, 2: Inactivo
    private Boolean emailVerified;
    private Long roleId; // FK to Role table
    
    // Default constructor
    public User() {
        this.emailVerified = false; // Por defecto no verificado
    }
    
    // Constructor with all fields
    public User(Long idUser, String username, String email, String password, 
               String name, String lastName, Integer age, String ci, Integer status, Long roleId) {
        this.idUser = idUser;
        this.username = username;
        this.email = email;
        this.password = password;
        this.name = name;
        this.lastName = lastName;
        this.age = age;
        this.ci = ci;
        this.status = status;
        this.emailVerified = false; // Por defecto no verificado
        this.roleId = roleId;
    }
    
    // Constructor without ID for creation
    public User(String username, String email, String password, 
               String name, String lastName, Integer age, String ci, Integer status, Long roleId) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.name = name;
        this.lastName = lastName;
        this.age = age;
        this.ci = ci;
        this.status = status;
        this.emailVerified = false; // Por defecto no verificado
        this.roleId = roleId;
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
    
    // Business logic methods
    public boolean isActive() {
        return status != null && status == 1; // 1 = Activo
    }
    
    public boolean isPending() {
        return status != null && status == 0; // 0 = Pendiente activación
    }
    
    public boolean isInactive() {
        return status != null && status == 2; // 2 = Inactivo
    }
    
    public void activate() {
        this.status = 1; // Activo
    }
    
    public void deactivate() {
        this.status = 2; // Inactivo
    }
    
    public void setPending() {
        this.status = 0; // Pendiente activación
    }
    
    public String getFullName() {
        return (name != null ? name : "") + " " + (lastName != null ? lastName : "");
    }
    
    @Override
    public String toString() {
        return "User{" +
                "idUser=" + idUser +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", name='" + name + '\'' +
                ", lastName='" + lastName + '\'' +
                ", age=" + age +
                ", ci='" + ci + '\'' +
                ", status=" + status +
                '}';
    }
}
