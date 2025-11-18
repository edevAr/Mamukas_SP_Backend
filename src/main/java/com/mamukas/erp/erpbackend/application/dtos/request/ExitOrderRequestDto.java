package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;

public class ExitOrderRequestDto {
    
    @NotNull(message = "Customer ID cannot be null")
    @Positive(message = "Customer ID must be positive")
    private Long idCustomer;
    
    @NotNull(message = "Date cannot be null")
    private LocalDate date;
    
    @NotBlank(message = "Status cannot be blank")
    private String status;
    
    // Constructors
    public ExitOrderRequestDto() {}
    
    public ExitOrderRequestDto(Long idCustomer, LocalDate date, String status) {
        this.idCustomer = idCustomer;
        this.date = date;
        this.status = status;
    }
    
    // Getters and setters
    public Long getIdCustomer() {
        return idCustomer;
    }
    
    public void setIdCustomer(Long idCustomer) {
        this.idCustomer = idCustomer;
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
