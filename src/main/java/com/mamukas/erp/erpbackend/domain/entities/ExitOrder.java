package com.mamukas.erp.erpbackend.domain.entities;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ExitOrder {
    
    private Long idOrder;
    private Long idCustomer;
    private LocalDate date;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<DetailOrder> details;
    
    // Constructors
    public ExitOrder() {
        this.details = new ArrayList<>();
    }
    
    public ExitOrder(Long idCustomer, LocalDate date, String status) {
        this.idCustomer = idCustomer;
        this.date = date;
        this.status = status;
        this.details = new ArrayList<>();
    }
    
    public ExitOrder(Long idOrder, Long idCustomer, LocalDate date, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idOrder = idOrder;
        this.idCustomer = idCustomer;
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
    public boolean hasValidCustomer() {
        return idCustomer != null && idCustomer > 0;
    }
    
    public boolean hasValidDate() {
        return date != null;
    }
    
    public boolean hasValidStatus() {
        return status != null && (status.equals("Pending") || status.equals("Confirmed") || 
                status.equals("Completed") || status.equals("Cancelled"));
    }
    
    public boolean isValidOrder() {
        return hasValidCustomer() && hasValidDate() && hasValidStatus();
    }
    
    // Getters and setters
    public Long getIdOrder() {
        return idOrder;
    }
    
    public void setIdOrder(Long idOrder) {
        this.idOrder = idOrder;
    }
    
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
        return "ExitOrder{" +
                "idOrder=" + idOrder +
                ", idCustomer=" + idCustomer +
                ", date=" + date +
                ", status='" + status + '\'' +
                ", totalAmount=" + getTotalAmount() +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
