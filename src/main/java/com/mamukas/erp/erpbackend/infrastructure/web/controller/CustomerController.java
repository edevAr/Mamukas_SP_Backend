package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.CustomerRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.CustomerResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.MessageResponseDto;
import com.mamukas.erp.erpbackend.application.services.CustomerService;
import com.mamukas.erp.erpbackend.domain.entities.Customer;
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
@RequestMapping("/api/customers")
@CrossOrigin(origins = "*")
public class CustomerController {
    
    @Autowired
    private CustomerService customerService;
    
    @PreAuthorize("hasAuthority('CUSTOMERS_CREATE') or hasRole('ADMIN')")
    @PostMapping
    public ResponseEntity<CustomerResponseDto> createCustomer(@Valid @RequestBody CustomerRequestDto request) {
        try {
            Customer customer = customerService.createCustomer(
                request.getName(),
                request.getNit()
            );
            CustomerResponseDto response = convertToResponseDto(customer);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @PreAuthorize("hasAuthority('CUSTOMERS_READ') or hasRole('ADMIN')")
    @GetMapping
    public ResponseEntity<List<CustomerResponseDto>> getAllCustomers() {
        try {
            List<Customer> customers = customerService.findAll();
            List<CustomerResponseDto> response = customers.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<CustomerResponseDto> getCustomerById(@PathVariable Long id) {
        try {
            Optional<Customer> customer = customerService.findById(id);
            if (customer.isPresent()) {
                CustomerResponseDto response = convertToResponseDto(customer.get());
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/nit/{nit}")
    public ResponseEntity<CustomerResponseDto> getCustomerByNit(@PathVariable String nit) {
        try {
            Optional<Customer> customer = customerService.findByNit(nit);
            if (customer.isPresent()) {
                CustomerResponseDto response = convertToResponseDto(customer.get());
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/search/name")
    public ResponseEntity<List<CustomerResponseDto>> searchCustomersByName(@RequestParam String name) {
        try {
            List<Customer> customers = customerService.findByNameContaining(name);
            List<CustomerResponseDto> response = customers.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<CustomerResponseDto>> searchCustomers(@RequestParam String term) {
        try {
            List<Customer> customers = customerService.searchCustomers(term);
            List<CustomerResponseDto> response = customers.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<CustomerResponseDto> updateCustomer(@PathVariable Long id, @Valid @RequestBody CustomerRequestDto request) {
        try {
            Customer customer = customerService.updateCustomer(
                id,
                request.getName(),
                request.getNit()
            );
            CustomerResponseDto response = convertToResponseDto(customer);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }
    
    @GetMapping("/count")
    public ResponseEntity<Long> countCustomers() {
        try {
            long count = customerService.countCustomers();
            return new ResponseEntity<>(count, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponseDto> deleteCustomer(@PathVariable Long id) {
        try {
            customerService.deleteCustomer(id);
            return new ResponseEntity<>(new MessageResponseDto("Customer deleted successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Customer not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    private CustomerResponseDto convertToResponseDto(Customer customer) {
        return new CustomerResponseDto(
            customer.getCustomerId(),
            customer.getName(),
            customer.getNit(),
            customer.getCreatedAt(),
            customer.getUpdatedAt()
        );
    }
}
