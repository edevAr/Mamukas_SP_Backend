package com.mamukas.erp.erpbackend.domain.entities;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Domain entity representing a sale transaction
 */
public class Sale {
    private Long idSale;
    private LocalDateTime date;
    private Long idProduct;
    private Long idCustomer;
    private Integer amount;
    private BigDecimal subtotal;
    private BigDecimal discount;
    private BigDecimal total;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Default constructor
    public Sale() {
        this.date = LocalDateTime.now();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.discount = BigDecimal.ZERO;
        this.amount = 1;
    }

    // Constructor for creation
    public Sale(Long idProduct, Long idCustomer, Integer amount, BigDecimal subtotal) {
        this();
        this.idProduct = idProduct;
        this.idCustomer = idCustomer;
        this.amount = amount;
        this.subtotal = subtotal;
        calculateTotal();
    }

    // Constructor with discount
    public Sale(Long idProduct, Long idCustomer, Integer amount, BigDecimal subtotal, BigDecimal discount) {
        this(idProduct, idCustomer, amount, subtotal);
        this.discount = discount != null ? discount : BigDecimal.ZERO;
        calculateTotal();
    }

    // Full constructor
    public Sale(Long idSale, LocalDateTime date, Long idProduct, Long idCustomer, 
               Integer amount, BigDecimal subtotal, BigDecimal discount, BigDecimal total,
               LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idSale = idSale;
        this.date = date;
        this.idProduct = idProduct;
        this.idCustomer = idCustomer;
        this.amount = amount;
        this.subtotal = subtotal;
        this.discount = discount;
        this.total = total;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Business methods
    public void calculateTotal() {
        if (subtotal != null) {
            BigDecimal discountAmount = discount != null ? discount : BigDecimal.ZERO;
            this.total = subtotal.subtract(discountAmount);
            this.updatedAt = LocalDateTime.now();
        }
    }

    public void applyDiscount(BigDecimal discountAmount) {
        if (discountAmount != null && discountAmount.compareTo(BigDecimal.ZERO) >= 0) {
            this.discount = discountAmount;
            calculateTotal();
        }
    }

    public void updateAmount(Integer newAmount) {
        if (newAmount != null && newAmount > 0) {
            this.amount = newAmount;
            this.updatedAt = LocalDateTime.now();
        }
    }

    public boolean isValidSale() {
        return idProduct != null && idCustomer != null && 
               amount != null && amount > 0 &&
               subtotal != null && subtotal.compareTo(BigDecimal.ZERO) > 0;
    }

    public BigDecimal getTotalWithoutDiscount() {
        return subtotal != null ? subtotal : BigDecimal.ZERO;
    }

    public BigDecimal getDiscountPercentage() {
        if (subtotal != null && subtotal.compareTo(BigDecimal.ZERO) > 0 && 
            discount != null && discount.compareTo(BigDecimal.ZERO) > 0) {
            return discount.divide(subtotal, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
        }
        return BigDecimal.ZERO;
    }

    // Getters and setters
    public Long getIdSale() {
        return idSale;
    }

    public void setIdSale(Long idSale) {
        this.idSale = idSale;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
        this.updatedAt = LocalDateTime.now();
    }

    public Long getIdProduct() {
        return idProduct;
    }

    public void setIdProduct(Long idProduct) {
        this.idProduct = idProduct;
        this.updatedAt = LocalDateTime.now();
    }

    public Long getIdCustomer() {
        return idCustomer;
    }

    public void setIdCustomer(Long idCustomer) {
        this.idCustomer = idCustomer;
        this.updatedAt = LocalDateTime.now();
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
        this.updatedAt = LocalDateTime.now();
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
        calculateTotal();
    }

    public BigDecimal getDiscount() {
        return discount;
    }

    public void setDiscount(BigDecimal discount) {
        this.discount = discount;
        calculateTotal();
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
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
        Sale sale = (Sale) o;
        return idSale != null && idSale.equals(sale.idSale);
    }

    @Override
    public int hashCode() {
        return idSale != null ? idSale.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "Sale{" +
                "idSale=" + idSale +
                ", date=" + date +
                ", idProduct=" + idProduct +
                ", idCustomer=" + idCustomer +
                ", amount=" + amount +
                ", subtotal=" + subtotal +
                ", discount=" + discount +
                ", total=" + total +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
