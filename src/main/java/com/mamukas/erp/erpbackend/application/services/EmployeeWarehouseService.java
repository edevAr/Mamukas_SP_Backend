package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.domain.entities.EmployeeWarehouse;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.EmployeeWarehouseJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.EmployeeWarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class EmployeeWarehouseService {
    
    @Autowired
    private EmployeeWarehouseRepository employeeWarehouseRepository;
    
    /**
     * Save employee-warehouse relationship
     */
    public EmployeeWarehouse save(EmployeeWarehouse employeeWarehouse) {
        EmployeeWarehouseJpaEntity entity = employeeWarehouseRepository.toEntity(employeeWarehouse);
        EmployeeWarehouseJpaEntity savedEntity = employeeWarehouseRepository.save(entity);
        return employeeWarehouseRepository.toDomain(savedEntity);
    }
    
    /**
     * Assign employee to warehouse
     */
    public EmployeeWarehouse assignEmployeeToWarehouse(Long idUser, Long idWarehouse) {
        // Check if relationship already exists
        Optional<EmployeeWarehouseJpaEntity> existing = employeeWarehouseRepository.findByIdUserAndIdWarehouse(idUser, idWarehouse);
        if (existing.isPresent()) {
            throw new RuntimeException("Employee is already assigned to this warehouse");
        }
        
        EmployeeWarehouse employeeWarehouse = new EmployeeWarehouse(idUser, idWarehouse);
        return save(employeeWarehouse);
    }
    
    /**
     * Remove employee from warehouse
     */
    public void removeEmployeeFromWarehouse(Long idUser, Long idWarehouse) {
        Optional<EmployeeWarehouseJpaEntity> existing = employeeWarehouseRepository.findByIdUserAndIdWarehouse(idUser, idWarehouse);
        if (existing.isPresent()) {
            employeeWarehouseRepository.deleteByIdUserAndIdWarehouse(idUser, idWarehouse);
        } else {
            throw new RuntimeException("Employee is not assigned to this warehouse");
        }
    }
    
    /**
     * Find warehouses by employee
     */
    @Transactional(readOnly = true)
    public List<EmployeeWarehouse> findWarehousesByEmployee(Long idUser) {
        return employeeWarehouseRepository.findWarehousesByEmployee(idUser)
                .stream()
                .map(employeeWarehouseRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find employees by warehouse
     */
    @Transactional(readOnly = true)
    public List<EmployeeWarehouse> findEmployeesByWarehouse(Long idWarehouse) {
        return employeeWarehouseRepository.findEmployeesByWarehouse(idWarehouse)
                .stream()
                .map(employeeWarehouseRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Check if employee is assigned to warehouse
     */
    @Transactional(readOnly = true)
    public boolean isEmployeeAssignedToWarehouse(Long idUser, Long idWarehouse) {
        return employeeWarehouseRepository.findByIdUserAndIdWarehouse(idUser, idWarehouse).isPresent();
    }
    
    /**
     * Find all employee-warehouse relationships
     */
    @Transactional(readOnly = true)
    public List<EmployeeWarehouse> findAll() {
        return employeeWarehouseRepository.findAll()
                .stream()
                .map(employeeWarehouseRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find by ID
     */
    @Transactional(readOnly = true)
    public Optional<EmployeeWarehouse> findById(Long id) {
        Optional<EmployeeWarehouseJpaEntity> entity = employeeWarehouseRepository.findById(id);
        return entity.map(employeeWarehouseRepository::toDomain);
    }
    
    /**
     * Delete employee-warehouse relationship by ID
     */
    public void deleteById(Long id) {
        if (employeeWarehouseRepository.existsById(id)) {
            employeeWarehouseRepository.deleteById(id);
        } else {
            throw new RuntimeException("Employee-Warehouse relationship not found with id: " + id);
        }
    }
}
