package com.mamukas.erp.erpbackend.application.dtos.response;

public class RegisterResponseDto {

    private Long idUser;
    private String username;
    private String email;
    private String name;
    private String lastName;
    private String message;

    // Constructors
    public RegisterResponseDto() {}

    public RegisterResponseDto(Long idUser, String username, String email, String name, 
                             String lastName, String message) {
        this.idUser = idUser;
        this.username = username;
        this.email = email;
        this.name = name;
        this.lastName = lastName;
        this.message = message;
    }

    // Getters and setters
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
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
