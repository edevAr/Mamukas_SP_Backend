package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.SaleRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.SaleResponseDto;
import com.mamukas.erp.erpbackend.application.services.SaleService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/sales")
@CrossOrigin(origins = "*")
public class SaleController {

    @Autowired
    private SaleService saleService;

    /**
     * Create a new sale
     */
    @PostMapping
    public ResponseEntity<SaleResponseDto> createSale(@Valid @RequestBody SaleRequestDto request) {
        try {
            SaleResponseDto response = saleService.createSale(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get all sales
     */
    @GetMapping
    public ResponseEntity<List<SaleResponseDto>> getAllSales() {
        try {
            List<SaleResponseDto> sales = saleService.getAllSales();
            return ResponseEntity.ok(sales);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get sale by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<SaleResponseDto> getSaleById(@PathVariable Long id) {
        try {
            SaleResponseDto sale = saleService.getSaleById(id);
            return ResponseEntity.ok(sale);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Update a sale
     */
    @PutMapping("/{id}")
    public ResponseEntity<SaleResponseDto> updateSale(@PathVariable Long id, @Valid @RequestBody SaleRequestDto request) {
        try {
            SaleResponseDto response = saleService.updateSale(id, request);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Delete a sale
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteSale(@PathVariable Long id) {
        try {
            boolean deleted = saleService.deleteSale(id);
            if (deleted) {
                return ResponseEntity.ok("Venta eliminada exitosamente");
            } else {
                return ResponseEntity.badRequest().body("Error al eliminar venta");
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno del servidor");
        }
    }

    /**
     * Get sales by product
     */
    @GetMapping("/product/{idProduct}")
    public ResponseEntity<List<SaleResponseDto>> getSalesByProduct(@PathVariable Long idProduct) {
        try {
            List<SaleResponseDto> sales = saleService.getSalesByProduct(idProduct);
            return ResponseEntity.ok(sales);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get sales by customer
     */
    @GetMapping("/customer/{idCustomer}")
    public ResponseEntity<List<SaleResponseDto>> getSalesByCustomer(@PathVariable Long idCustomer) {
        try {
            List<SaleResponseDto> sales = saleService.getSalesByCustomer(idCustomer);
            return ResponseEntity.ok(sales);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get sales by date range
     */
    @GetMapping("/date-range")
    public ResponseEntity<List<SaleResponseDto>> getSalesByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        try {
            List<SaleResponseDto> sales = saleService.getSalesByDateRange(startDate, endDate);
            return ResponseEntity.ok(sales);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get sales by total range
     */
    @GetMapping("/total-range")
    public ResponseEntity<List<SaleResponseDto>> getSalesByTotalRange(
            @RequestParam BigDecimal minTotal,
            @RequestParam BigDecimal maxTotal) {
        try {
            List<SaleResponseDto> sales = saleService.getSalesByTotalRange(minTotal, maxTotal);
            return ResponseEntity.ok(sales);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get sales by customer and date range
     */
    @GetMapping("/customer/{idCustomer}/date-range")
    public ResponseEntity<List<SaleResponseDto>> getSalesByCustomerAndDateRange(
            @PathVariable Long idCustomer,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        try {
            List<SaleResponseDto> sales = saleService.getSalesByCustomerAndDateRange(idCustomer, startDate, endDate);
            return ResponseEntity.ok(sales);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get sales by product and date range
     */
    @GetMapping("/product/{idProduct}/date-range")
    public ResponseEntity<List<SaleResponseDto>> getSalesByProductAndDateRange(
            @PathVariable Long idProduct,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        try {
            List<SaleResponseDto> sales = saleService.getSalesByProductAndDateRange(idProduct, startDate, endDate);
            return ResponseEntity.ok(sales);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get total sales by date range
     */
    @GetMapping("/analytics/total-by-date-range")
    public ResponseEntity<BigDecimal> getTotalSalesByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        try {
            BigDecimal total = saleService.getTotalSalesByDateRange(startDate, endDate);
            return ResponseEntity.ok(total);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get total sales by customer
     */
    @GetMapping("/analytics/total-by-customer/{idCustomer}")
    public ResponseEntity<BigDecimal> getTotalSalesByCustomer(@PathVariable Long idCustomer) {
        try {
            BigDecimal total = saleService.getTotalSalesByCustomer(idCustomer);
            return ResponseEntity.ok(total);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Apply discount to sale
     */
    @PutMapping("/{id}/discount")
    public ResponseEntity<SaleResponseDto> applyDiscount(@PathVariable Long id, @RequestParam BigDecimal discount) {
        try {
            SaleResponseDto response = saleService.applyDiscount(id, discount);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get sale count
     */
    @GetMapping("/count")
    public ResponseEntity<Long> getSaleCount() {
        try {
            long count = saleService.getSaleCount();
            return ResponseEntity.ok(count);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
