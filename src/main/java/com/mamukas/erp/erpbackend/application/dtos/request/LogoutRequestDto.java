package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotBlank;

public class LogoutRequestDto {

    @NotBlank(message = "El token no puede estar vacío")
    private String token;

    // Constructors
    public LogoutRequestDto() {}

    public LogoutRequestDto(String token) {
        this.token = token;
    }

    // Getters and setters
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
