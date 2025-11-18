package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class ResetPasswordRequestDto {

    @NotBlank(message = "El token no puede estar vacío")
    private String token;

    @NotBlank(message = "La contraseña no puede estar vacía")
    @Size(min = 6, max = 100, message = "La contraseña debe tener entre 6 y 100 caracteres")
    private String password;

    @NotBlank(message = "La confirmación de contraseña no puede estar vacía")
    private String confirmPassword;

    // Constructors
    public ResetPasswordRequestDto() {}

    public ResetPasswordRequestDto(String token, String password, String confirmPassword) {
        this.token = token;
        this.password = password;
        this.confirmPassword = confirmPassword;
    }

    // Getters and setters
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
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
}
