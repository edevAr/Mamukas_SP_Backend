package com.mamukas.erp.erpbackend.domain.entities;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class EntryOrder {
    
    private Long idOrder;
    private Long idProvider;
    private LocalDate date;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<DetailOrder> details;
    
    // Constructors
    public EntryOrder() {
        this.details = new ArrayList<>();
    }
    
    public EntryOrder(Long idProvider, LocalDate date, String status) {
        this.idProvider = idProvider;
        this.date = date;
        this.status = status;
        this.details = new ArrayList<>();
    }
    
    public EntryOrder(Long idOrder, Long idProvider, LocalDate date, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idOrder = idOrder;
        this.idProvider = idProvider;
        this.date = date;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.details = new ArrayList<>();
    }
    
    // Business methods
    public void addDetail(DetailOrder detail) {
        if (detail != null) {
            this.details.add(detail);
        }
    }
    
    public void removeDetail(DetailOrder detail) {
        if (detail != null) {
            this.details.remove(detail);
        }
    }
    
    public BigDecimal getTotalAmount() {
        return details.stream()
                .map(DetailOrder::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
    
    public void pending() {
        this.status = "Pending";
    }
    
    public void confirm() {
        this.status = "Confirmed";
    }
    
    public void complete() {
        this.status = "Completed";
    }
    
    public void cancel() {
        this.status = "Cancelled";
    }
    
    public boolean isPending() {
        return "Pending".equals(this.status);
    }
    
    public boolean isConfirmed() {
        return "Confirmed".equals(this.status);
    }
    
    public boolean isCompleted() {
        return "Completed".equals(this.status);
    }
    
    public boolean isCancelled() {
        return "Cancelled".equals(this.status);
    }
    
    // Validation methods
    public boolean hasValidProvider() {
        return idProvider != null && idProvider > 0;
    }
    
    public boolean hasValidDate() {
        return date != null;
    }
    
    public boolean hasValidStatus() {
        return status != null && (status.equals("Pending") || status.equals("Confirmed") || 
                status.equals("Completed") || status.equals("Cancelled"));
    }
    
    public boolean isValidOrder() {
        return hasValidProvider() && hasValidDate() && hasValidStatus();
    }
    
    // Getters and setters
    public Long getIdOrder() {
        return idOrder;
    }
    
    public void setIdOrder(Long idOrder) {
        this.idOrder = idOrder;
    }
    
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
    
    public List<DetailOrder> getDetails() {
        return details;
    }
    
    public void setDetails(List<DetailOrder> details) {
        this.details = details != null ? details : new ArrayList<>();
    }
    
    @Override
    public String toString() {
        return "EntryOrder{" +
                "idOrder=" + idOrder +
                ", idProvider=" + idProvider +
                ", date=" + date +
                ", status='" + status + '\'' +
                ", totalAmount=" + getTotalAmount() +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
