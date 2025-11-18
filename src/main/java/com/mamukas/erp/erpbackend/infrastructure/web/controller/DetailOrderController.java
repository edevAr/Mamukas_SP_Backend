package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.DetailOrderRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.DetailOrderResponseDto;
import com.mamukas.erp.erpbackend.application.services.DetailOrderService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/detail-orders")
@CrossOrigin(origins = "*")
public class DetailOrderController {
    
    @Autowired
    private DetailOrderService detailOrderService;
    
    // Create a new detail order
    @PreAuthorize("hasAuthority('SALES_CREATE') or hasAuthority('PURCHASES_CREATE') or hasRole('ADMIN')")
    @PostMapping
    public ResponseEntity<DetailOrderResponseDto> create(@Valid @RequestBody DetailOrderRequestDto request) {
        try {
            DetailOrderResponseDto response = detailOrderService.create(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    // Get detail order by ID
    @PreAuthorize("hasAuthority('SALES_READ') or hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/{id}")
    public ResponseEntity<DetailOrderResponseDto> findById(@PathVariable Long id) {
        Optional<DetailOrderResponseDto> response = detailOrderService.findById(id);
        return response.map(detail -> new ResponseEntity<>(detail, HttpStatus.OK))
                      .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
    
    // Get all detail orders
    @PreAuthorize("hasAuthority('SALES_READ') or hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping
    public ResponseEntity<List<DetailOrderResponseDto>> findAll() {
        List<DetailOrderResponseDto> responses = detailOrderService.findAll();
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Get detail orders by order ID
    @PreAuthorize("hasAuthority('SALES_READ') or hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/order/{idOrder}")
    public ResponseEntity<List<DetailOrderResponseDto>> findByIdOrder(@PathVariable Long idOrder) {
        List<DetailOrderResponseDto> responses = detailOrderService.findByIdOrder(idOrder);
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Get detail orders by product ID
    @PreAuthorize("hasAuthority('INVENTORY_READ') or hasRole('ADMIN')")
    @GetMapping("/product/{idProduct}")
    public ResponseEntity<List<DetailOrderResponseDto>> findByIdProduct(@PathVariable Long idProduct) {
        List<DetailOrderResponseDto> responses = detailOrderService.findByIdProduct(idProduct);
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Get detail orders by amount range
    @PreAuthorize("hasAuthority('SALES_READ') or hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/amount-range")
    public ResponseEntity<List<DetailOrderResponseDto>> findByAmountRange(
            @RequestParam BigDecimal minAmount, 
            @RequestParam BigDecimal maxAmount) {
        List<DetailOrderResponseDto> responses = detailOrderService.findByAmountRange(minAmount, maxAmount);
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Update detail order
    @PreAuthorize("hasAuthority('SALES_UPDATE') or hasAuthority('PURCHASES_UPDATE') or hasRole('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<DetailOrderResponseDto> update(@PathVariable Long id, 
                                                       @Valid @RequestBody DetailOrderRequestDto request) {
        try {
            Optional<DetailOrderResponseDto> response = detailOrderService.update(id, request);
            return response.map(detail -> new ResponseEntity<>(detail, HttpStatus.OK))
                          .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    // Delete detail order
    @PreAuthorize("hasAuthority('SALES_DELETE') or hasAuthority('PURCHASES_DELETE') or hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        boolean deleted = detailOrderService.delete(id);
        return deleted ? new ResponseEntity<>(HttpStatus.NO_CONTENT) 
                       : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
    
    // Get total amount for an order
    @PreAuthorize("hasAuthority('SALES_READ') or hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/total-amount/{idOrder}")
    public ResponseEntity<BigDecimal> getTotalAmountByOrder(@PathVariable Long idOrder) {
        BigDecimal totalAmount = detailOrderService.getTotalAmountByOrder(idOrder);
        return new ResponseEntity<>(totalAmount, HttpStatus.OK);
    }
    
    // Get count of detail orders for an order
    @PreAuthorize("hasAuthority('SALES_READ') or hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/count/{idOrder}")
    public ResponseEntity<Long> getCountByOrder(@PathVariable Long idOrder) {
        long count = detailOrderService.getCountByOrder(idOrder);
        return new ResponseEntity<>(count, HttpStatus.OK);
    }
    
    // Get count of detail orders for a product
    @PreAuthorize("hasAuthority('INVENTORY_READ') or hasRole('ADMIN')")
    @GetMapping("/count/product/{idProduct}")
    public ResponseEntity<Long> getCountByProduct(@PathVariable Long idProduct) {
        long count = detailOrderService.getCountByProduct(idProduct);
        return new ResponseEntity<>(count, HttpStatus.OK);
    }
    
    // Get total amount for a product
    @PreAuthorize("hasAuthority('INVENTORY_READ') or hasRole('ADMIN')")
    @GetMapping("/total-amount/product/{idProduct}")
    public ResponseEntity<BigDecimal> getTotalAmountByProduct(@PathVariable Long idProduct) {
        BigDecimal totalAmount = detailOrderService.getTotalAmountByProduct(idProduct);
        return new ResponseEntity<>(totalAmount, HttpStatus.OK);
    }
}
