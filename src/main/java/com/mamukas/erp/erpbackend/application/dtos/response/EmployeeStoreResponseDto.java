package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDateTime;

public class EmployeeStoreResponseDto {
    private Long idEmployeeStore;
    private Long idEmployee;
    private Long idStore;
    private String employeeName;
    private String storeName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public EmployeeStoreResponseDto() {}

    public EmployeeStoreResponseDto(Long idEmployeeStore, Long idEmployee, Long idStore, 
                                   LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idEmployeeStore = idEmployeeStore;
        this.idEmployee = idEmployee;
        this.idStore = idStore;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public EmployeeStoreResponseDto(Long idEmployeeStore, Long idEmployee, Long idStore, 
                                   String employeeName, String storeName,
                                   LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idEmployeeStore = idEmployeeStore;
        this.idEmployee = idEmployee;
        this.idStore = idStore;
        this.employeeName = employeeName;
        this.storeName = storeName;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and setters
    public Long getIdEmployeeStore() {
        return idEmployeeStore;
    }

    public void setIdEmployeeStore(Long idEmployeeStore) {
        this.idEmployeeStore = idEmployeeStore;
    }

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

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }

    public String getStoreName() {
        return storeName;
    }

    public void setStoreName(String storeName) {
        this.storeName = storeName;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
