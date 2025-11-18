package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

public class PackRequestDto {
    
    @NotNull(message = "El ID del producto no puede estar vacío")
    @Positive(message = "El ID del producto debe ser un número positivo")
    private Long idProduct;
    
    @NotBlank(message = "El nombre no puede estar vacío")
    @Size(max = 255, message = "El nombre no puede exceder 255 caracteres")
    private String name;
    
    @Future(message = "La fecha de expiración debe ser en el futuro")
    private LocalDate expirationDate;
    
    @NotNull(message = "Las unidades no pueden estar vacías")
    @PositiveOrZero(message = "Las unidades deben ser un número positivo o cero")
    private Integer units;
    
    // Constructors
    public PackRequestDto() {}
    
    public PackRequestDto(Long idProduct, String name, LocalDate expirationDate, Integer units) {
        this.idProduct = idProduct;
        this.name = name;
        this.expirationDate = expirationDate;
        this.units = units;
    }
    
    // Getters and setters
    public Long getIdProduct() {
        return idProduct;
    }
    
    public void setIdProduct(Long idProduct) {
        this.idProduct = idProduct;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public LocalDate getExpirationDate() {
        return expirationDate;
    }
    
    public void setExpirationDate(LocalDate expirationDate) {
        this.expirationDate = expirationDate;
    }
    
    public Integer getUnits() {
        return units;
    }
    
    public void setUnits(Integer units) {
        this.units = units;
    }
}
