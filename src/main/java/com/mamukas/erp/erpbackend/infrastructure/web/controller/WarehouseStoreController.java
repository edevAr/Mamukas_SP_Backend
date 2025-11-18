package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.WarehouseStoreRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.MessageResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.WarehouseStoreResponseDto;
import com.mamukas.erp.erpbackend.application.services.WarehouseStoreService;
import com.mamukas.erp.erpbackend.domain.entities.WarehouseStore;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/warehouse-stores")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('USER')")
public class WarehouseStoreController {
    
    @Autowired
    private WarehouseStoreService warehouseStoreService;
    
    @PostMapping
    public ResponseEntity<WarehouseStoreResponseDto> assignStoreToWarehouse(@Valid @RequestBody WarehouseStoreRequestDto request) {
        try {
            WarehouseStore warehouseStore = warehouseStoreService.assignStoreToWarehouse(request.getIdWarehouse(), request.getIdStore());
            WarehouseStoreResponseDto response = convertToResponseDto(warehouseStore);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @DeleteMapping
    public ResponseEntity<MessageResponseDto> removeStoreFromWarehouse(@Valid @RequestBody WarehouseStoreRequestDto request) {
        try {
            warehouseStoreService.removeStoreFromWarehouse(request.getIdWarehouse(), request.getIdStore());
            return new ResponseEntity<>(new MessageResponseDto("Store removed from warehouse successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Warehouse-Store relationship not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponseDto> deleteById(@PathVariable Long id) {
        try {
            warehouseStoreService.deleteById(id);
            return new ResponseEntity<>(new MessageResponseDto("Warehouse-Store relationship deleted successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Warehouse-Store relationship not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    @GetMapping("/warehouse/{idWarehouse}")
    public ResponseEntity<List<WarehouseStoreResponseDto>> getStoresByWarehouse(@PathVariable Long idWarehouse) {
        try {
            List<WarehouseStore> warehouseStores = warehouseStoreService.findStoresByWarehouse(idWarehouse);
            List<WarehouseStoreResponseDto> response = warehouseStores.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/store/{idStore}")
    public ResponseEntity<List<WarehouseStoreResponseDto>> getWarehousesByStore(@PathVariable Long idStore) {
        try {
            List<WarehouseStore> warehouseStores = warehouseStoreService.findWarehousesByStore(idStore);
            List<WarehouseStoreResponseDto> response = warehouseStores.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/check")
    public ResponseEntity<MessageResponseDto> checkAssignment(@RequestParam Long idWarehouse, @RequestParam Long idStore) {
        try {
            boolean isAssigned = warehouseStoreService.isStoreAssignedToWarehouse(idWarehouse, idStore);
            String message = isAssigned ? "Store is assigned to warehouse" : "Store is not assigned to warehouse";
            return new ResponseEntity<>(new MessageResponseDto(message), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Error checking assignment"), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping
    public ResponseEntity<List<WarehouseStoreResponseDto>> getAllWarehouseStores() {
        try {
            List<WarehouseStore> warehouseStores = warehouseStoreService.findAll();
            List<WarehouseStoreResponseDto> response = warehouseStores.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    private WarehouseStoreResponseDto convertToResponseDto(WarehouseStore warehouseStore) {
        return new WarehouseStoreResponseDto(
            warehouseStore.getIdWarehouseStore(),
            warehouseStore.getIdWarehouse(),
            warehouseStore.getIdStore(),
            warehouseStore.getCreatedAt(),
            warehouseStore.getUpdatedAt()
        );
    }
}
