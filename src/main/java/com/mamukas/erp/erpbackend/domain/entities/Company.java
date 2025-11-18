package com.mamukas.erp.erpbackend.domain.entities;

import java.time.LocalDateTime;

/**
 * Domain entity representing a company
 */
public class Company {
    private Long idCompany;
    private String name;
    private String address;
    private String status;
    private String businessHours;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constants for status
    public static final String STATUS_OPENED = "Opened";
    public static final String STATUS_CLOSED = "Closed";

    // Default constructor
    public Company() {
        this.status = STATUS_OPENED;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor for creation
    public Company(String name, String address, String businessHours) {
        this();
        this.name = name;
        this.address = address;
        this.businessHours = businessHours;
    }

    // Constructor with status
    public Company(String name, String address, String status, String businessHours) {
        this(name, address, businessHours);
        this.status = status;
    }

    // Constructor with ID
    public Company(Long idCompany, String name, String address, String status, String businessHours) {
        this(name, address, status, businessHours);
        this.idCompany = idCompany;
    }

    // Full constructor
    public Company(Long idCompany, String name, String address, String status, String businessHours, 
                  LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idCompany = idCompany;
        this.name = name;
        this.address = address;
        this.status = status;
        this.businessHours = businessHours;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Business methods
    public void open() {
        this.status = STATUS_OPENED;
        this.updatedAt = LocalDateTime.now();
    }

    public void close() {
        this.status = STATUS_CLOSED;
        this.updatedAt = LocalDateTime.now();
    }

    public boolean isOpened() {
        return STATUS_OPENED.equals(this.status);
    }

    public boolean isClosed() {
        return STATUS_CLOSED.equals(this.status);
    }

    public void updateName(String newName) {
        if (newName == null || newName.trim().isEmpty()) {
            throw new IllegalArgumentException("Company name cannot be null or empty");
        }
        this.name = newName.trim();
        this.updatedAt = LocalDateTime.now();
    }

    public void updateAddress(String newAddress) {
        if (newAddress == null || newAddress.trim().isEmpty()) {
            throw new IllegalArgumentException("Company address cannot be null or empty");
        }
        this.address = newAddress.trim();
        this.updatedAt = LocalDateTime.now();
    }

    public void updateBusinessHours(String newBusinessHours) {
        this.businessHours = newBusinessHours;
        this.updatedAt = LocalDateTime.now();
    }

    public boolean isValidCompany() {
        return name != null && !name.trim().isEmpty() && 
               address != null && !address.trim().isEmpty() &&
               status != null && (STATUS_OPENED.equals(status) || STATUS_CLOSED.equals(status));
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
        this.updatedAt = LocalDateTime.now();
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
        this.updatedAt = LocalDateTime.now();
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();
    }

    public String getBusinessHours() {
        return businessHours;
    }

    public void setBusinessHours(String businessHours) {
        this.businessHours = businessHours;
        this.updatedAt = LocalDateTime.now();
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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Company company = (Company) o;
        return idCompany != null && idCompany.equals(company.idCompany);
    }

    @Override
    public int hashCode() {
        return idCompany != null ? idCompany.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "Company{" +
                "idCompany=" + idCompany +
                ", name='" + name + '\'' +
                ", address='" + address + '\'' +
                ", status='" + status + '\'' +
                ", businessHours='" + businessHours + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
