package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;

public class ProductRequestDto {
    
    @NotBlank(message = "El nombre no puede estar vacío")
    @Size(max = 255, message = "El nombre no puede exceder 255 caracteres")
    private String name;
    
    @Pattern(regexp = "^(Active|Inactive)$", message = "El estado debe ser 'Active' o 'Inactive'")
    private String status = "Active";
    
    @NotNull(message = "El precio no puede estar vacío")
    @DecimalMin(value = "0.0", inclusive = true, message = "El precio debe ser mayor o igual a 0")
    @Digits(integer = 8, fraction = 2, message = "El precio debe tener máximo 8 dígitos enteros y 2 decimales")
    private BigDecimal price;
    
    @Future(message = "La fecha de expiración debe ser en el futuro")
    private LocalDate expirationDate;
    
    // Constructors
    public ProductRequestDto() {}
    
    public ProductRequestDto(String name, String status, BigDecimal price, LocalDate expirationDate) {
        this.name = name;
        this.status = status;
        this.price = price;
        this.expirationDate = expirationDate;
    }
    
    // Getters and setters
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public BigDecimal getPrice() {
        return price;
    }
    
    public void setPrice(BigDecimal price) {
        this.price = price;
    }
    
    public LocalDate getExpirationDate() {
        return expirationDate;
    }
    
    public void setExpirationDate(LocalDate expirationDate) {
        this.expirationDate = expirationDate;
    }
}
