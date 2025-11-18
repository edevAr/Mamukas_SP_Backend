package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;

public class EntryOrderRequestDto {
    
    @NotNull(message = "Provider ID cannot be null")
    @Positive(message = "Provider ID must be positive")
    private Long idProvider;
    
    @NotNull(message = "Date cannot be null")
    private LocalDate date;
    
    @NotBlank(message = "Status cannot be blank")
    private String status;
    
    // Constructors
    public EntryOrderRequestDto() {}
    
    public EntryOrderRequestDto(Long idProvider, LocalDate date, String status) {
        this.idProvider = idProvider;
        this.date = date;
        this.status = status;
    }
    
    // Getters and setters
    public Long getIdProvider() {
        return idProvider;
    }
    
    public void setIdProvider(Long idProvider) {
        this.idProvider = idProvider;
    }
    
    public LocalDate getDate() {
        return date;
    }
    
    public void setDate(LocalDate date) {
        this.date = date;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
}
