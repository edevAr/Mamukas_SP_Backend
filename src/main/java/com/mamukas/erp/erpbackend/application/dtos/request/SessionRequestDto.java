package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class SessionRequestDto {
    
    @NotNull(message = "El ID del usuario no puede ser nulo")
    private Long idUser;
    
    @NotBlank(message = "El dispositivo no puede estar vacío")
    private String device;
    
    @NotBlank(message = "La IP no puede estar vacía")
    private String ip;
    
    // Constructors
    public SessionRequestDto() {}
    
    public SessionRequestDto(Long idUser, String device, String ip) {
        this.idUser = idUser;
        this.device = device;
        this.ip = ip;
    }
    
    // Getters and setters
    public Long getIdUser() {
        return idUser;
    }
    
    public void setIdUser(Long idUser) {
        this.idUser = idUser;
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
