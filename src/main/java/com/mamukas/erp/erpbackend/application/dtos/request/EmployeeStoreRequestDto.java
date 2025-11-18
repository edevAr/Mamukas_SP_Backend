package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.NotNull;

public class EmployeeStoreRequestDto {

    @NotNull(message = "El ID del empleado no puede ser nulo")
    private Long idEmployee;

    @NotNull(message = "El ID de la tienda no puede ser nulo")
    private Long idStore;

    // Constructors
    public EmployeeStoreRequestDto() {}

    public EmployeeStoreRequestDto(Long idEmployee, Long idStore) {
        this.idEmployee = idEmployee;
        this.idStore = idStore;
    }

    // Getters and setters
    public Long getIdEmployee() {
        return idEmployee;
    }

    public void setIdEmployee(Long idEmployee) {
        this.idEmployee = idEmployee;
    }

    public Long getIdStore() {
        return idStore;
    }

    public void setIdStore(Long idStore) {
        this.idStore = idStore;
    }
}
