package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class LoginRequestDto {

    @NotBlank(message = "El usuario o email no puede estar vacío")
    private String usernameOrEmail;

    @NotBlank(message = "La contraseña no puede estar vacía")
    @Size(min = 6, message = "La contraseña debe tener al menos 6 caracteres")
    private String password;

    @NotBlank(message = "El dispositivo no puede estar vacío")
    private String device;

    @NotBlank(message = "La IP no puede estar vacía")
    private String ip;

    // Constructors
    public LoginRequestDto() {}

    public LoginRequestDto(String usernameOrEmail, String password) {
        this.usernameOrEmail = usernameOrEmail;
        this.password = password;
    }

    public LoginRequestDto(String usernameOrEmail, String password, String device, String ip) {
        this.usernameOrEmail = usernameOrEmail;
        this.password = password;
        this.device = device;
        this.ip = ip;
    }

    // Getters and setters
    public String getUsernameOrEmail() {
        return usernameOrEmail;
    }

    public void setUsernameOrEmail(String usernameOrEmail) {
        this.usernameOrEmail = usernameOrEmail;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getDevice() {
        return device;
    }

    public void setDevice(String device) {
        this.device = device;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }
}
