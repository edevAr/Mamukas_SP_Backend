package com.mamukas.erp.erpbackend.application.dtos.response;

public class LoginResponseDto {

    private Long idUser;
    private String username;
    private String email;
    private String fullName;
    private String accessToken;
    private String refreshToken;
    private String message;

    // Constructors
    public LoginResponseDto() {}

    public LoginResponseDto(Long idUser, String username, String email, String fullName,
                           String accessToken, String refreshToken, String message) {
        this.idUser = idUser;
        this.username = username;
        this.email = email;
        this.fullName = fullName;
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
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

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
