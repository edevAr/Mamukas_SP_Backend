package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.ExitOrderRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.ExitOrderResponseDto;
import com.mamukas.erp.erpbackend.application.services.ExitOrderService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/exit-orders")
@CrossOrigin(origins = "*")
public class ExitOrderController {
    
    @Autowired
    private ExitOrderService exitOrderService;
    
    // Create a new exit order
    @PreAuthorize("hasAuthority('SALES_CREATE') or hasRole('ADMIN')")
    @PostMapping
    public ResponseEntity<ExitOrderResponseDto> create(@Valid @RequestBody ExitOrderRequestDto request) {
        try {
            ExitOrderResponseDto response = exitOrderService.create(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    // Get exit order by ID
    @PreAuthorize("hasAuthority('SALES_READ') or hasRole('ADMIN')")
    @GetMapping("/{id}")
    public ResponseEntity<ExitOrderResponseDto> findById(@PathVariable Long id) {
        Optional<ExitOrderResponseDto> response = exitOrderService.findById(id);
        return response.map(order -> new ResponseEntity<>(order, HttpStatus.OK))
                      .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
    
    // Get all exit orders
    @PreAuthorize("hasAuthority('SALES_READ') or hasRole('ADMIN')")
    @GetMapping
    public ResponseEntity<List<ExitOrderResponseDto>> findAll() {
        List<ExitOrderResponseDto> responses = exitOrderService.findAll();
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Get exit orders by customer ID
    @PreAuthorize("hasAuthority('SALES_READ') or hasRole('ADMIN')")
    @GetMapping("/customer/{idCustomer}")
    public ResponseEntity<List<ExitOrderResponseDto>> findByIdCustomer(@PathVariable Long idCustomer) {
        List<ExitOrderResponseDto> responses = exitOrderService.findByIdCustomer(idCustomer);
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Get exit orders by status
    @PreAuthorize("hasAuthority('SALES_READ') or hasRole('ADMIN')")
    @GetMapping("/status/{status}")
    public ResponseEntity<List<ExitOrderResponseDto>> findByStatus(@PathVariable String status) {
        List<ExitOrderResponseDto> responses = exitOrderService.findByStatus(status);
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Get exit orders by date range
    @PreAuthorize("hasAuthority('SALES_READ') or hasRole('ADMIN')")
    @GetMapping("/date-range")
    public ResponseEntity<List<ExitOrderResponseDto>> findByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<ExitOrderResponseDto> responses = exitOrderService.findByDateRange(startDate, endDate);
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Update exit order
    @PreAuthorize("hasAuthority('SALES_UPDATE') or hasRole('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<ExitOrderResponseDto> update(@PathVariable Long id, 
                                                     @Valid @RequestBody ExitOrderRequestDto request) {
        try {
            Optional<ExitOrderResponseDto> response = exitOrderService.update(id, request);
            return response.map(order -> new ResponseEntity<>(order, HttpStatus.OK))
                          .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    // Update status only
    @PreAuthorize("hasAuthority('SALES_UPDATE') or hasRole('ADMIN')")
    @PatchMapping("/{id}/status")
    public ResponseEntity<ExitOrderResponseDto> updateStatus(@PathVariable Long id, 
                                                           @RequestParam String status) {
        try {
            Optional<ExitOrderResponseDto> response = exitOrderService.updateStatus(id, status);
            return response.map(order -> new ResponseEntity<>(order, HttpStatus.OK))
                          .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    // Delete exit order
    @PreAuthorize("hasAuthority('SALES_DELETE') or hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        boolean deleted = exitOrderService.delete(id);
        return deleted ? new ResponseEntity<>(HttpStatus.NO_CONTENT) 
                       : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
    
    // Get count by customer
    @PreAuthorize("hasAuthority('SALES_READ') or hasRole('ADMIN')")
    @GetMapping("/count/customer/{idCustomer}")
    public ResponseEntity<Long> getCountByCustomer(@PathVariable Long idCustomer) {
        long count = exitOrderService.getCountByCustomer(idCustomer);
        return new ResponseEntity<>(count, HttpStatus.OK);
    }
    
    // Get count by status
    @PreAuthorize("hasAuthority('SALES_READ') or hasRole('ADMIN')")
    @GetMapping("/count/status/{status}")
    public ResponseEntity<Long> getCountByStatus(@PathVariable String status) {
        long count = exitOrderService.getCountByStatus(status);
        return new ResponseEntity<>(count, HttpStatus.OK);
    }
}
