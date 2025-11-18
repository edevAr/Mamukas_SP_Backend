package com.mamukas.erp.erpbackend.application.dtos.response;

import java.time.LocalDateTime;

public class CompanyResponseDto {
    private Long idCompany;
    private String name;
    private String address;
    private String status;
    private String businessHours;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public CompanyResponseDto() {}

    public CompanyResponseDto(Long idCompany, String name, String address, String status, 
                             String businessHours, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idCompany = idCompany;
        this.name = name;
        this.address = address;
        this.status = status;
        this.businessHours = businessHours;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and setters
    public Long getIdCompany() {
        return idCompany;
    }

    public void setIdCompany(Long idCompany) {
        this.idCompany = idCompany;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getBusinessHours() {
        return businessHours;
    }

    public void setBusinessHours(String businessHours) {
        this.businessHours = businessHours;
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
