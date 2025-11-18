package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.EmployeeWarehouseRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.EmployeeWarehouseResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.MessageResponseDto;
import com.mamukas.erp.erpbackend.application.services.EmployeeWarehouseService;
import com.mamukas.erp.erpbackend.domain.entities.EmployeeWarehouse;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/employee-warehouses")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('USER')")
public class EmployeeWarehouseController {
    
    @Autowired
    private EmployeeWarehouseService employeeWarehouseService;
    
    @PostMapping
    public ResponseEntity<EmployeeWarehouseResponseDto> assignEmployeeToWarehouse(@Valid @RequestBody EmployeeWarehouseRequestDto request) {
        try {
            EmployeeWarehouse employeeWarehouse = employeeWarehouseService.assignEmployeeToWarehouse(request.getIdUser(), request.getIdWarehouse());
            EmployeeWarehouseResponseDto response = convertToResponseDto(employeeWarehouse);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @DeleteMapping
    public ResponseEntity<MessageResponseDto> removeEmployeeFromWarehouse(@Valid @RequestBody EmployeeWarehouseRequestDto request) {
        try {
            employeeWarehouseService.removeEmployeeFromWarehouse(request.getIdUser(), request.getIdWarehouse());
            return new ResponseEntity<>(new MessageResponseDto("Employee removed from warehouse successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Employee-Warehouse relationship not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponseDto> deleteById(@PathVariable Long id) {
        try {
            employeeWarehouseService.deleteById(id);
            return new ResponseEntity<>(new MessageResponseDto("Employee-Warehouse relationship deleted successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Employee-Warehouse relationship not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    @GetMapping("/employee/{idUser}")
    public ResponseEntity<List<EmployeeWarehouseResponseDto>> getWarehousesByEmployee(@PathVariable Long idUser) {
        try {
            List<EmployeeWarehouse> employeeWarehouses = employeeWarehouseService.findWarehousesByEmployee(idUser);
            List<EmployeeWarehouseResponseDto> response = employeeWarehouses.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/warehouse/{idWarehouse}")
    public ResponseEntity<List<EmployeeWarehouseResponseDto>> getEmployeesByWarehouse(@PathVariable Long idWarehouse) {
        try {
            List<EmployeeWarehouse> employeeWarehouses = employeeWarehouseService.findEmployeesByWarehouse(idWarehouse);
            List<EmployeeWarehouseResponseDto> response = employeeWarehouses.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/check")
    public ResponseEntity<MessageResponseDto> checkAssignment(@RequestParam Long idUser, @RequestParam Long idWarehouse) {
        try {
            boolean isAssigned = employeeWarehouseService.isEmployeeAssignedToWarehouse(idUser, idWarehouse);
            String message = isAssigned ? "Employee is assigned to warehouse" : "Employee is not assigned to warehouse";
            return new ResponseEntity<>(new MessageResponseDto(message), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Error checking assignment"), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping
    public ResponseEntity<List<EmployeeWarehouseResponseDto>> getAllEmployeeWarehouses() {
        try {
            List<EmployeeWarehouse> employeeWarehouses = employeeWarehouseService.findAll();
            List<EmployeeWarehouseResponseDto> response = employeeWarehouses.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    private EmployeeWarehouseResponseDto convertToResponseDto(EmployeeWarehouse employeeWarehouse) {
        return new EmployeeWarehouseResponseDto(
            employeeWarehouse.getIdEmployeeWarehouse(),
            employeeWarehouse.getIdUser(),
            employeeWarehouse.getIdWarehouse(),
            employeeWarehouse.getCreatedAt(),
            employeeWarehouse.getUpdatedAt()
        );
    }
}
