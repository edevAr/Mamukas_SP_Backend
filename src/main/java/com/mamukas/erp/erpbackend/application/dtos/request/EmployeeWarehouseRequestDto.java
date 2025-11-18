package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotNull;

public class EmployeeWarehouseRequestDto {
    
    @NotNull(message = "El ID del usuario no puede ser nulo")
    private Long idUser;
    
    @NotNull(message = "El ID del almacén no puede ser nulo")
    private Long idWarehouse;
    
    // Constructors
    public EmployeeWarehouseRequestDto() {}
    
    public EmployeeWarehouseRequestDto(Long idUser, Long idWarehouse) {
        this.idUser = idUser;
        this.idWarehouse = idWarehouse;
    }
    
    // Getters and setters
    public Long getIdUser() {
        return idUser;
    }
    
    public void setIdUser(Long idUser) {
        this.idUser = idUser;
    }
    
    public Long getIdWarehouse() {
        return idWarehouse;
    }
    
    public void setIdWarehouse(Long idWarehouse) {
        this.idWarehouse = idWarehouse;
    }
}
