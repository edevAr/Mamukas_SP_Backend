package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.domain.entities.Store;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.StoreJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.StoreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class StoreService {
    
    @Autowired
    private StoreRepository storeRepository;
    
    /**
     * Save store
     */
    public Store save(Store store) {
        StoreJpaEntity entity = storeRepository.toEntity(store);
        StoreJpaEntity savedEntity = storeRepository.save(entity);
        return storeRepository.toDomain(savedEntity);
    }
    
    /**
     * Create new store
     */
    public Store createStore(String name, String address, String businessHours, Long idCompany) {
        Store store = new Store(name, address, "Open", businessHours, idCompany);
        return save(store);
    }
    
    /**
     * Find store by ID
     */
    @Transactional(readOnly = true)
    public Optional<Store> findById(Long id) {
        Optional<StoreJpaEntity> entity = storeRepository.findByIdStore(id);
        return entity.map(storeRepository::toDomain);
    }
    
    /**
     * Find all stores
     */
    @Transactional(readOnly = true)
    public List<Store> findAll() {
        return storeRepository.findAll()
                .stream()
                .map(storeRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find stores by status
     */
    @Transactional(readOnly = true)
    public List<Store> findByStatus(String status) {
        return storeRepository.findByStatus(status)
                .stream()
                .map(storeRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find open stores
     */
    @Transactional(readOnly = true)
    public List<Store> findOpenStores() {
        return findByStatus("Open");
    }
    
    /**
     * Find closed stores
     */
    @Transactional(readOnly = true)
    public List<Store> findClosedStores() {
        return findByStatus("Close");
    }
    
    /**
     * Find stores by name containing text
     */
    @Transactional(readOnly = true)
    public List<Store> findByNameContaining(String name) {
        return storeRepository.findByNameContaining(name)
                .stream()
                .map(storeRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find stores by address containing text
     */
    @Transactional(readOnly = true)
    public List<Store> findByAddressContaining(String address) {
        return storeRepository.findByAddressContaining(address)
                .stream()
                .map(storeRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find store by name
     */
    @Transactional(readOnly = true)
    public Optional<Store> findByName(String name) {
        Optional<StoreJpaEntity> entity = storeRepository.findByName(name);
        return entity.map(storeRepository::toDomain);
    }
    
    /**
     * Update store
     */
    public Store updateStore(Long id, String name, String address, String status, String businessHours, Long idCompany) {
        Optional<StoreJpaEntity> entityOpt = storeRepository.findByIdStore(id);
        if (entityOpt.isPresent()) {
            Store store = storeRepository.toDomain(entityOpt.get());
            store.setName(name);
            store.setAddress(address);
            store.setStatus(status);
            store.setBusinessHours(businessHours);
            store.setIdCompany(idCompany);
            return save(store);
        }
        throw new RuntimeException("Store not found with id: " + id);
    }
    
    /**
     * Open store
     */
    public Store openStore(Long id) {
        Optional<StoreJpaEntity> entityOpt = storeRepository.findByIdStore(id);
        if (entityOpt.isPresent()) {
            Store store = storeRepository.toDomain(entityOpt.get());
            store.open();
            return save(store);
        }
        throw new RuntimeException("Store not found with id: " + id);
    }
    
    /**
     * Close store
     */
    public Store closeStore(Long id) {
        Optional<StoreJpaEntity> entityOpt = storeRepository.findByIdStore(id);
        if (entityOpt.isPresent()) {
            Store store = storeRepository.toDomain(entityOpt.get());
            store.close();
            return save(store);
        }
        throw new RuntimeException("Store not found with id: " + id);
    }
    
    /**
     * Check if store exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return storeRepository.existsById(id);
    }
    
    /**
     * Delete store
     */
    public void deleteStore(Long id) {
        if (storeRepository.existsById(id)) {
            storeRepository.deleteById(id);
        } else {
            throw new RuntimeException("Store not found with id: " + id);
        }
    }
}
