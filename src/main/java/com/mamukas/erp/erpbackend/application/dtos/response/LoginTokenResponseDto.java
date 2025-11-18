package com.mamukas.erp.erpbackend.application.dtos.response;

public class LoginTokenResponseDto {
    private String accessToken;
    private String refreshToken;

    // Constructors
    public LoginTokenResponseDto() {}

    public LoginTokenResponseDto(String accessToken, String refreshToken) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
    }

    // Getters and setters
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
}
