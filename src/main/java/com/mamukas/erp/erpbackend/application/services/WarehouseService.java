package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.domain.entities.Warehouse;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.WarehouseJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class WarehouseService {
    
    @Autowired
    private WarehouseRepository warehouseRepository;
    
    /**
     * Save warehouse
     */
    public Warehouse save(Warehouse warehouse) {
        WarehouseJpaEntity entity = warehouseRepository.toEntity(warehouse);
        WarehouseJpaEntity savedEntity = warehouseRepository.save(entity);
        return warehouseRepository.toDomain(savedEntity);
    }
    
    /**
     * Create new warehouse
     */
    public Warehouse createWarehouse(String address) {
        Warehouse warehouse = new Warehouse(address, "Active");
        return save(warehouse);
    }
    
    /**
     * Find warehouse by ID
     */
    @Transactional(readOnly = true)
    public Optional<Warehouse> findById(Long id) {
        Optional<WarehouseJpaEntity> entity = warehouseRepository.findByIdWarehouse(id);
        return entity.map(warehouseRepository::toDomain);
    }
    
    /**
     * Find all warehouses
     */
    @Transactional(readOnly = true)
    public List<Warehouse> findAll() {
        return warehouseRepository.findAll()
                .stream()
                .map(warehouseRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find warehouses by status
     */
    @Transactional(readOnly = true)
    public List<Warehouse> findByStatus(String status) {
        return warehouseRepository.findByStatus(status)
                .stream()
                .map(warehouseRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find active warehouses
     */
    @Transactional(readOnly = true)
    public List<Warehouse> findActiveWarehouses() {
        return findByStatus("Active");
    }
    
    /**
     * Find warehouses by address containing text
     */
    @Transactional(readOnly = true)
    public List<Warehouse> findByAddressContaining(String address) {
        return warehouseRepository.findByAddressContaining(address)
                .stream()
                .map(warehouseRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Update warehouse
     */
    public Warehouse updateWarehouse(Long id, String address, String status) {
        Optional<WarehouseJpaEntity> entityOpt = warehouseRepository.findByIdWarehouse(id);
        if (entityOpt.isPresent()) {
            Warehouse warehouse = warehouseRepository.toDomain(entityOpt.get());
            warehouse.setAddress(address);
            warehouse.setStatus(status);
            return save(warehouse);
        }
        throw new RuntimeException("Warehouse not found with id: " + id);
    }
    
    /**
     * Activate warehouse
     */
    public Warehouse activateWarehouse(Long id) {
        Optional<WarehouseJpaEntity> entityOpt = warehouseRepository.findByIdWarehouse(id);
        if (entityOpt.isPresent()) {
            Warehouse warehouse = warehouseRepository.toDomain(entityOpt.get());
            warehouse.activate();
            return save(warehouse);
        }
        throw new RuntimeException("Warehouse not found with id: " + id);
    }
    
    /**
     * Deactivate warehouse
     */
    public Warehouse deactivateWarehouse(Long id) {
        Optional<WarehouseJpaEntity> entityOpt = warehouseRepository.findByIdWarehouse(id);
        if (entityOpt.isPresent()) {
            Warehouse warehouse = warehouseRepository.toDomain(entityOpt.get());
            warehouse.deactivate();
            return save(warehouse);
        }
        throw new RuntimeException("Warehouse not found with id: " + id);
    }
    
    /**
     * Delete warehouse
     */
    public void deleteWarehouse(Long id) {
        if (warehouseRepository.existsById(id)) {
            warehouseRepository.deleteById(id);
        } else {
            throw new RuntimeException("Warehouse not found with id: " + id);
        }
    }
}
