package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.WarehouseRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.MessageResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.WarehouseResponseDto;
import com.mamukas.erp.erpbackend.application.services.WarehouseService;
import com.mamukas.erp.erpbackend.domain.entities.Warehouse;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/warehouses")
@CrossOrigin(origins = "*")
public class WarehouseController {
    
    @Autowired
    private WarehouseService warehouseService;
    
    @PostMapping
    public ResponseEntity<WarehouseResponseDto> createWarehouse(@Valid @RequestBody WarehouseRequestDto request) {
        try {
            Warehouse warehouse = warehouseService.createWarehouse(request.getAddress());
            if (request.getStatus() != null && !request.getStatus().equals("Active")) {
                warehouse = warehouseService.updateWarehouse(warehouse.getIdWarehouse(), warehouse.getAddress(), request.getStatus());
            }
            
            WarehouseResponseDto response = convertToResponseDto(warehouse);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @GetMapping
    public ResponseEntity<List<WarehouseResponseDto>> getAllWarehouses() {
        try {
            List<Warehouse> warehouses = warehouseService.findAll();
            List<WarehouseResponseDto> response = warehouses.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<WarehouseResponseDto> getWarehouseById(@PathVariable Long id) {
        try {
            Optional<Warehouse> warehouse = warehouseService.findById(id);
            if (warehouse.isPresent()) {
                WarehouseResponseDto response = convertToResponseDto(warehouse.get());
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/active")
    public ResponseEntity<List<WarehouseResponseDto>> getActiveWarehouses() {
        try {
            List<Warehouse> warehouses = warehouseService.findActiveWarehouses();
            List<WarehouseResponseDto> response = warehouses.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/status/{status}")
    public ResponseEntity<List<WarehouseResponseDto>> getWarehousesByStatus(@PathVariable String status) {
        try {
            List<Warehouse> warehouses = warehouseService.findByStatus(status);
            List<WarehouseResponseDto> response = warehouses.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<WarehouseResponseDto>> searchWarehousesByAddress(@RequestParam String address) {
        try {
            List<Warehouse> warehouses = warehouseService.findByAddressContaining(address);
            List<WarehouseResponseDto> response = warehouses.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<WarehouseResponseDto> updateWarehouse(@PathVariable Long id, @Valid @RequestBody WarehouseRequestDto request) {
        try {
            Warehouse warehouse = warehouseService.updateWarehouse(id, request.getAddress(), request.getStatus());
            WarehouseResponseDto response = convertToResponseDto(warehouse);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }
    
    @PutMapping("/{id}/activate")
    public ResponseEntity<MessageResponseDto> activateWarehouse(@PathVariable Long id) {
        try {
            warehouseService.activateWarehouse(id);
            return new ResponseEntity<>(new MessageResponseDto("Warehouse activated successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Warehouse not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    @PutMapping("/{id}/deactivate")
    public ResponseEntity<MessageResponseDto> deactivateWarehouse(@PathVariable Long id) {
        try {
            warehouseService.deactivateWarehouse(id);
            return new ResponseEntity<>(new MessageResponseDto("Warehouse deactivated successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Warehouse not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponseDto> deleteWarehouse(@PathVariable Long id) {
        try {
            warehouseService.deleteWarehouse(id);
            return new ResponseEntity<>(new MessageResponseDto("Warehouse deleted successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Warehouse not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    private WarehouseResponseDto convertToResponseDto(Warehouse warehouse) {
        return new WarehouseResponseDto(
            warehouse.getIdWarehouse(),
            warehouse.getAddress(),
            warehouse.getStatus(),
            warehouse.getCreatedAt(),
            warehouse.getUpdatedAt()
        );
    }
}
