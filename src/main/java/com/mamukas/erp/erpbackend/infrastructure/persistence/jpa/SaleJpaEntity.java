package com.mamukas.erp.erpbackend.infrastructure.persistence.jpa;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "sales")
public class SaleJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_sale")
    private Long idSale;

    @Column(name = "date", nullable = false)
    private LocalDateTime date;

    @Column(name = "id_product", nullable = false)
    private Long idProduct;

    @Column(name = "id_customer", nullable = false)
    private Long idCustomer;

    @Column(name = "amount", nullable = false)
    private Integer amount;

    @Column(name = "subtotal", nullable = false, precision = 10, scale = 2)
    private BigDecimal subtotal;

    @Column(name = "discount", precision = 10, scale = 2)
    private BigDecimal discount;

    @Column(name = "total", nullable = false, precision = 10, scale = 2)
    private BigDecimal total;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public SaleJpaEntity() {
        this.date = LocalDateTime.now();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.discount = BigDecimal.ZERO;
        this.amount = 1;
    }

    // Constructor for creation
    public SaleJpaEntity(Long idProduct, Long idCustomer, Integer amount, BigDecimal subtotal) {
        this();
        this.idProduct = idProduct;
        this.idCustomer = idCustomer;
        this.amount = amount;
        this.subtotal = subtotal;
        calculateTotal();
    }

    // Constructor with discount
    public SaleJpaEntity(Long idProduct, Long idCustomer, Integer amount, 
                        BigDecimal subtotal, BigDecimal discount) {
        this(idProduct, idCustomer, amount, subtotal);
        this.discount = discount != null ? discount : BigDecimal.ZERO;
        calculateTotal();
    }

    // Lifecycle callbacks
    @PrePersist
    protected void onCreate() {
        this.date = LocalDateTime.now();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        calculateTotal();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
        calculateTotal();
    }

    // Business method
    private void calculateTotal() {
        if (subtotal != null) {
            BigDecimal discountAmount = discount != null ? discount : BigDecimal.ZERO;
            this.total = subtotal.subtract(discountAmount);
        }
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
    }

    public Long getIdProduct() {
        return idProduct;
    }

    public void setIdProduct(Long idProduct) {
        this.idProduct = idProduct;
    }

    public Long getIdCustomer() {
        return idCustomer;
    }

    public void setIdCustomer(Long idCustomer) {
        this.idCustomer = idCustomer;
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
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
        SaleJpaEntity that = (SaleJpaEntity) o;
        return idSale != null && idSale.equals(that.idSale);
    }

    @Override
    public int hashCode() {
        return idSale != null ? idSale.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "SaleJpaEntity{" +
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
