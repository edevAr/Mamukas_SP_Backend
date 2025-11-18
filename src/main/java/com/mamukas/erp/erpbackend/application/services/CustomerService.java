package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.domain.entities.Customer;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.CustomerJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class CustomerService {
    
    @Autowired
    private CustomerRepository customerRepository;
    
    /**
     * Save customer
     */
    public Customer save(Customer customer) {
        CustomerJpaEntity entity = customerRepository.toEntity(customer);
        CustomerJpaEntity savedEntity = customerRepository.save(entity);
        return customerRepository.toDomain(savedEntity);
    }
    
    /**
     * Create new customer
     */
    public Customer createCustomer(String name, String nit) {
        if (customerRepository.existsByNit(nit)) {
            throw new RuntimeException("Customer with NIT already exists: " + nit);
        }
        
        Customer customer = new Customer(name, nit);
        if (!customer.isValidCustomer()) {
            throw new RuntimeException("Invalid customer data");
        }
        
        return save(customer);
    }
    
    /**
     * Find customer by ID
     */
    @Transactional(readOnly = true)
    public Optional<Customer> findById(Long id) {
        Optional<CustomerJpaEntity> entity = customerRepository.findByCustomerId(id);
        return entity.map(customerRepository::toDomain);
    }
    
    /**
     * Find all customers
     */
    @Transactional(readOnly = true)
    public List<Customer> findAll() {
        return customerRepository.findAll()
                .stream()
                .map(customerRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find customer by NIT
     */
    @Transactional(readOnly = true)
    public Optional<Customer> findByNit(String nit) {
        Optional<CustomerJpaEntity> entity = customerRepository.findByNit(nit);
        return entity.map(customerRepository::toDomain);
    }
    
    /**
     * Find customers by name containing text
     */
    @Transactional(readOnly = true)
    public List<Customer> findByNameContaining(String name) {
        return customerRepository.findByNameContaining(name)
                .stream()
                .map(customerRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Search customers by term (name or nit)
     */
    @Transactional(readOnly = true)
    public List<Customer> searchCustomers(String searchTerm) {
        return customerRepository.searchCustomers(searchTerm)
                .stream()
                .map(customerRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Update customer
     */
    public Customer updateCustomer(Long id, String name, String nit) {
        Optional<CustomerJpaEntity> entityOpt = customerRepository.findByCustomerId(id);
        if (entityOpt.isPresent()) {
            Customer existingCustomer = customerRepository.toDomain(entityOpt.get());
            
            // Check if NIT is being changed and if it already exists
            if (!existingCustomer.getNit().equals(nit) && customerRepository.existsByNit(nit)) {
                throw new RuntimeException("Customer with NIT already exists: " + nit);
            }
            
            existingCustomer.setName(name);
            existingCustomer.setNit(nit);
            
            if (!existingCustomer.isValidCustomer()) {
                throw new RuntimeException("Invalid customer data");
            }
            
            return save(existingCustomer);
        }
        throw new RuntimeException("Customer not found with id: " + id);
    }
    
    /**
     * Count all customers
     */
    @Transactional(readOnly = true)
    public long countCustomers() {
        return customerRepository.countAllCustomers();
    }
    
    /**
     * Check if customer exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return customerRepository.existsById(id);
    }
    
    /**
     * Check if customer exists by NIT
     */
    @Transactional(readOnly = true)
    public boolean existsByNit(String nit) {
        return customerRepository.existsByNit(nit);
    }
    
    /**
     * Delete customer
     */
    public void deleteCustomer(Long id) {
        if (customerRepository.existsById(id)) {
            customerRepository.deleteById(id);
        } else {
            throw new RuntimeException("Customer not found with id: " + id);
        }
    }
}
