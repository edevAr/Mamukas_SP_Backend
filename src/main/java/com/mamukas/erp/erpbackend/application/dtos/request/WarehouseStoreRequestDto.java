package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotNull;

public class WarehouseStoreRequestDto {
    
    @NotNull(message = "El ID del almacén no puede ser nulo")
    private Long idWarehouse;
    
    @NotNull(message = "El ID de la tienda no puede ser nulo")
    private Long idStore;
    
    // Constructors
    public WarehouseStoreRequestDto() {}
    
    public WarehouseStoreRequestDto(Long idWarehouse, Long idStore) {
        this.idWarehouse = idWarehouse;
        this.idStore = idStore;
    }
    
    // Getters and setters
    public Long getIdWarehouse() {
        return idWarehouse;
    }
    
    public void setIdWarehouse(Long idWarehouse) {
        this.idWarehouse = idWarehouse;
    }
    
    public Long getIdStore() {
        return idStore;
    }
    
    public void setIdStore(Long idStore) {
        this.idStore = idStore;
    }
}
