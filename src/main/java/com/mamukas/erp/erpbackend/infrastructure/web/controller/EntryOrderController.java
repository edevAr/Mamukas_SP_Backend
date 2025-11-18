package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.EntryOrderRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.EntryOrderResponseDto;
import com.mamukas.erp.erpbackend.application.services.EntryOrderService;
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
@RequestMapping("/api/entry-orders")
@CrossOrigin(origins = "*")
public class EntryOrderController {
    
    @Autowired
    private EntryOrderService entryOrderService;
    
    // Create a new entry order
    @PreAuthorize("hasAuthority('PURCHASES_CREATE') or hasRole('ADMIN')")
    @PostMapping
    public ResponseEntity<EntryOrderResponseDto> create(@Valid @RequestBody EntryOrderRequestDto request) {
        try {
            EntryOrderResponseDto response = entryOrderService.create(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    // Get entry order by ID
    @PreAuthorize("hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/{id}")
    public ResponseEntity<EntryOrderResponseDto> findById(@PathVariable Long id) {
        Optional<EntryOrderResponseDto> response = entryOrderService.findById(id);
        return response.map(order -> new ResponseEntity<>(order, HttpStatus.OK))
                      .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
    
    // Get all entry orders
    @PreAuthorize("hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping
    public ResponseEntity<List<EntryOrderResponseDto>> findAll() {
        List<EntryOrderResponseDto> responses = entryOrderService.findAll();
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Get entry orders by provider ID
    @PreAuthorize("hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/provider/{idProvider}")
    public ResponseEntity<List<EntryOrderResponseDto>> findByIdProvider(@PathVariable Long idProvider) {
        List<EntryOrderResponseDto> responses = entryOrderService.findByIdProvider(idProvider);
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Get entry orders by status
    @PreAuthorize("hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/status/{status}")
    public ResponseEntity<List<EntryOrderResponseDto>> findByStatus(@PathVariable String status) {
        List<EntryOrderResponseDto> responses = entryOrderService.findByStatus(status);
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Get entry orders by date range
    @PreAuthorize("hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/date-range")
    public ResponseEntity<List<EntryOrderResponseDto>> findByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<EntryOrderResponseDto> responses = entryOrderService.findByDateRange(startDate, endDate);
        return new ResponseEntity<>(responses, HttpStatus.OK);
    }
    
    // Update entry order
    @PreAuthorize("hasAuthority('PURCHASES_UPDATE') or hasRole('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<EntryOrderResponseDto> update(@PathVariable Long id, 
                                                      @Valid @RequestBody EntryOrderRequestDto request) {
        try {
            Optional<EntryOrderResponseDto> response = entryOrderService.update(id, request);
            return response.map(order -> new ResponseEntity<>(order, HttpStatus.OK))
                          .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    // Update status only
    @PreAuthorize("hasAuthority('PURCHASES_UPDATE') or hasRole('ADMIN')")
    @PatchMapping("/{id}/status")
    public ResponseEntity<EntryOrderResponseDto> updateStatus(@PathVariable Long id, 
                                                            @RequestParam String status) {
        try {
            Optional<EntryOrderResponseDto> response = entryOrderService.updateStatus(id, status);
            return response.map(order -> new ResponseEntity<>(order, HttpStatus.OK))
                          .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    // Delete entry order
    @PreAuthorize("hasAuthority('PURCHASES_DELETE') or hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        boolean deleted = entryOrderService.delete(id);
        return deleted ? new ResponseEntity<>(HttpStatus.NO_CONTENT) 
                       : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
    
    // Get count by provider
    @PreAuthorize("hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/count/provider/{idProvider}")
    public ResponseEntity<Long> getCountByProvider(@PathVariable Long idProvider) {
        long count = entryOrderService.getCountByProvider(idProvider);
        return new ResponseEntity<>(count, HttpStatus.OK);
    }
    
    // Get count by status
    @PreAuthorize("hasAuthority('PURCHASES_READ') or hasRole('ADMIN')")
    @GetMapping("/count/status/{status}")
    public ResponseEntity<Long> getCountByStatus(@PathVariable String status) {
        long count = entryOrderService.getCountByStatus(status);
        return new ResponseEntity<>(count, HttpStatus.OK);
    }
}
