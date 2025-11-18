package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class SaleRequestDto {

    private LocalDateTime date;

    @NotNull(message = "El ID del producto no puede ser nulo")
    private Long idProduct;

    @NotNull(message = "El ID del cliente no puede ser nulo")
    private Long idCustomer;

    @NotNull(message = "La cantidad no puede ser nula")
    @Min(value = 1, message = "La cantidad debe ser mayor a 0")
    private Integer amount;

    @NotNull(message = "El subtotal no puede ser nulo")
    @DecimalMin(value = "0.01", message = "El subtotal debe ser mayor a 0")
    private BigDecimal subtotal;

    @DecimalMin(value = "0.00", message = "El descuento no puede ser negativo")
    private BigDecimal discount;

    // Constructors
    public SaleRequestDto() {
        this.discount = BigDecimal.ZERO;
    }

    public SaleRequestDto(Long idProduct, Long idCustomer, Integer amount, BigDecimal subtotal) {
        this();
        this.idProduct = idProduct;
        this.idCustomer = idCustomer;
        this.amount = amount;
        this.subtotal = subtotal;
    }

    public SaleRequestDto(Long idProduct, Long idCustomer, Integer amount, 
                         BigDecimal subtotal, BigDecimal discount) {
        this(idProduct, idCustomer, amount, subtotal);
        this.discount = discount;
    }

    // Getters and setters
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
    }

    public BigDecimal getDiscount() {
        return discount;
    }

    public void setDiscount(BigDecimal discount) {
        this.discount = discount;
    }
}
