package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.domain.entities.Pack;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.PackJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.PackRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class PackService {

    @Autowired
    private PackRepository packRepository;

    /**
     * Save pack
     */
    public Pack save(Pack pack) {
        PackJpaEntity entity = packRepository.toEntity(pack);
        PackJpaEntity savedEntity = packRepository.save(entity);
        return packRepository.toDomain(savedEntity);
    }

    /**
     * Create new pack
     */
    public Pack createPack(Long idProduct, String name, LocalDate expirationDate, Integer units) {
        if (idProduct == null || idProduct <= 0) {
            throw new IllegalArgumentException("Product ID must be provided and valid");
        }
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Pack name must be provided");
        }
        if (units == null || units < 0) {
            throw new IllegalArgumentException("Units must be provided and non-negative");
        }

        Pack pack = new Pack(idProduct, name, expirationDate, units);
        return save(pack);
    }

    /**
     * Find pack by ID
     */
    @Transactional(readOnly = true)
    public Optional<Pack> findById(Long id) {
        Optional<PackJpaEntity> entity = packRepository.findByIdPack(id);
        return entity.map(packRepository::toDomain);
    }

    /**
     * Find all packs
     */
    @Transactional(readOnly = true)
    public List<Pack> findAll() {
        return packRepository.findAll()
                .stream()
                .map(packRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find packs by product ID
     */
    @Transactional(readOnly = true)
    public List<Pack> findByIdProduct(Long idProduct) {
        return packRepository.findByIdProduct(idProduct)
                .stream()
                .map(packRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find packs by name containing text
     */
    @Transactional(readOnly = true)
    public List<Pack> findByNameContaining(String name) {
        return packRepository.findByNameContaining(name)
                .stream()
                .map(packRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find packs expiring soon (within 7 days)
     */
    @Transactional(readOnly = true)
    public List<Pack> findExpiringSoon() {
        LocalDate endDate = LocalDate.now().plusDays(7);
        return packRepository.findByExpirationDateBetween(LocalDate.now(), endDate)
                .stream()
                .map(packRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find packs by expiration date before given date
     */
    @Transactional(readOnly = true)
    public List<Pack> findByExpirationDateBefore(LocalDate date) {
        return packRepository.findByExpirationDateBefore(date)
                .stream()
                .map(packRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find packs with stock
     */
    @Transactional(readOnly = true)
    public List<Pack> findPacksWithStock() {
        return packRepository.findPacksWithStock()
                .stream()
                .map(packRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find packs out of stock
     */
    @Transactional(readOnly = true)
    public List<Pack> findPacksOutOfStock() {
        return packRepository.findPacksOutOfStock()
                .stream()
                .map(packRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Update pack
     */
    public Pack updatePack(Long id, String name, LocalDate expirationDate, Integer units) {
        Optional<PackJpaEntity> entityOpt = packRepository.findByIdPack(id);
        if (entityOpt.isPresent()) {
            Pack pack = packRepository.toDomain(entityOpt.get());
            
            if (name != null && !name.trim().isEmpty()) {
                pack.setName(name);
            }
            if (expirationDate != null) {
                pack.setExpirationDate(expirationDate);
            }
            if (units != null && units >= 0) {
                pack.setUnits(units);
            }
            
            return save(pack);
        }
        throw new IllegalArgumentException("Pack not found with id: " + id);
    }

    /**
     * Add units to pack
     */
    public Pack addUnits(Long id, int additionalUnits) {
        Optional<PackJpaEntity> entityOpt = packRepository.findByIdPack(id);
        if (entityOpt.isPresent()) {
            Pack pack = packRepository.toDomain(entityOpt.get());
            pack.addUnits(additionalUnits);
            return save(pack);
        }
        throw new IllegalArgumentException("Pack not found with id: " + id);
    }

    /**
     * Remove units from pack
     */
    public Pack removeUnits(Long id, int unitsToRemove) {
        Optional<PackJpaEntity> entityOpt = packRepository.findByIdPack(id);
        if (entityOpt.isPresent()) {
            Pack pack = packRepository.toDomain(entityOpt.get());
            try {
                pack.removeUnits(unitsToRemove);
                return save(pack);
            } catch (RuntimeException e) {
                throw new IllegalArgumentException("Cannot remove units: " + e.getMessage());
            }
        }
        throw new IllegalArgumentException("Pack not found with id: " + id);
    }

    /**
     * Delete pack by ID
     */
    public void deleteById(Long id) {
        if (!packRepository.existsById(id)) {
            throw new IllegalArgumentException("Pack not found with id: " + id);
        }
        packRepository.deleteById(id);
    }

    /**
     * Check if pack exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return packRepository.existsById(id);
    }

    /**
     * Get total units by product
     */
    @Transactional(readOnly = true)
    public Long getTotalUnitsByProduct(Long idProduct) {
        Long total = packRepository.getTotalUnitsByProduct(idProduct);
        return total != null ? total : 0L;
    }

    /**
     * Find packs with stock by product
     */
    @Transactional(readOnly = true)
    public List<Pack> findPacksWithStockByProduct(Long idProduct) {
        return packRepository.findPacksWithStockByProduct(idProduct)
                .stream()
                .map(packRepository::toDomain)
                .collect(Collectors.toList());
    }
}
