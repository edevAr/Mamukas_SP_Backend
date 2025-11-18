package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.domain.entities.WarehouseStore;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.WarehouseStoreJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.WarehouseStoreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class WarehouseStoreService {
    
    @Autowired
    private WarehouseStoreRepository warehouseStoreRepository;
    
    /**
     * Save warehouse-store relationship
     */
    public WarehouseStore save(WarehouseStore warehouseStore) {
        WarehouseStoreJpaEntity entity = warehouseStoreRepository.toEntity(warehouseStore);
        WarehouseStoreJpaEntity savedEntity = warehouseStoreRepository.save(entity);
        return warehouseStoreRepository.toDomain(savedEntity);
    }
    
    /**
     * Assign store to warehouse
     */
    public WarehouseStore assignStoreToWarehouse(Long idWarehouse, Long idStore) {
        // Check if relationship already exists
        Optional<WarehouseStoreJpaEntity> existing = warehouseStoreRepository.findByIdWarehouseAndIdStore(idWarehouse, idStore);
        if (existing.isPresent()) {
            throw new RuntimeException("Store is already assigned to this warehouse");
        }
        
        WarehouseStore warehouseStore = new WarehouseStore(idWarehouse, idStore);
        return save(warehouseStore);
    }
    
    /**
     * Remove store from warehouse
     */
    public void removeStoreFromWarehouse(Long idWarehouse, Long idStore) {
        Optional<WarehouseStoreJpaEntity> existing = warehouseStoreRepository.findByIdWarehouseAndIdStore(idWarehouse, idStore);
        if (existing.isPresent()) {
            warehouseStoreRepository.deleteByIdWarehouseAndIdStore(idWarehouse, idStore);
        } else {
            throw new RuntimeException("Store is not assigned to this warehouse");
        }
    }
    
    /**
     * Find stores by warehouse
     */
    @Transactional(readOnly = true)
    public List<WarehouseStore> findStoresByWarehouse(Long idWarehouse) {
        return warehouseStoreRepository.findStoresByWarehouse(idWarehouse)
                .stream()
                .map(warehouseStoreRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find warehouses by store
     */
    @Transactional(readOnly = true)
    public List<WarehouseStore> findWarehousesByStore(Long idStore) {
        return warehouseStoreRepository.findWarehousesByStore(idStore)
                .stream()
                .map(warehouseStoreRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Check if store is assigned to warehouse
     */
    @Transactional(readOnly = true)
    public boolean isStoreAssignedToWarehouse(Long idWarehouse, Long idStore) {
        return warehouseStoreRepository.findByIdWarehouseAndIdStore(idWarehouse, idStore).isPresent();
    }
    
    /**
     * Find all warehouse-store relationships
     */
    @Transactional(readOnly = true)
    public List<WarehouseStore> findAll() {
        return warehouseStoreRepository.findAll()
                .stream()
                .map(warehouseStoreRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find by ID
     */
    @Transactional(readOnly = true)
    public Optional<WarehouseStore> findById(Long id) {
        Optional<WarehouseStoreJpaEntity> entity = warehouseStoreRepository.findById(id);
        return entity.map(warehouseStoreRepository::toDomain);
    }
    
    /**
     * Delete warehouse-store relationship by ID
     */
    public void deleteById(Long id) {
        if (warehouseStoreRepository.existsById(id)) {
            warehouseStoreRepository.deleteById(id);
        } else {
            throw new RuntimeException("Warehouse-Store relationship not found with id: " + id);
        }
    }
}
