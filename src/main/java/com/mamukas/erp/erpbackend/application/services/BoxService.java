package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.domain.entities.Box;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.BoxJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.BoxRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class BoxService {

    @Autowired
    private BoxRepository boxRepository;

    /**
     * Save box
     */
    public Box save(Box box) {
        BoxJpaEntity entity = boxRepository.toEntity(box);
        BoxJpaEntity savedEntity = boxRepository.save(entity);
        return boxRepository.toDomain(savedEntity);
    }

    /**
     * Create new box
     */
    public Box createBox(Long idProduct, String name, LocalDate expirationDate, Integer units) {
        if (idProduct == null || idProduct <= 0) {
            throw new IllegalArgumentException("Product ID must be provided and valid");
        }
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Box name must be provided");
        }
        if (units == null || units < 0) {
            throw new IllegalArgumentException("Units must be provided and non-negative");
        }

        Box box = new Box(idProduct, name, expirationDate, units);
        return save(box);
    }

    /**
     * Find box by ID
     */
    @Transactional(readOnly = true)
    public Optional<Box> findById(Long id) {
        Optional<BoxJpaEntity> entity = boxRepository.findByIdBox(id);
        return entity.map(boxRepository::toDomain);
    }

    /**
     * Find all boxes
     */
    @Transactional(readOnly = true)
    public List<Box> findAll() {
        return boxRepository.findAll()
                .stream()
                .map(boxRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find boxes by product ID
     */
    @Transactional(readOnly = true)
    public List<Box> findByIdProduct(Long idProduct) {
        return boxRepository.findByIdProduct(idProduct)
                .stream()
                .map(boxRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find boxes by name containing text
     */
    @Transactional(readOnly = true)
    public List<Box> findByNameContaining(String name) {
        return boxRepository.findByNameContaining(name)
                .stream()
                .map(boxRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find boxes expiring soon (within 7 days)
     */
    @Transactional(readOnly = true)
    public List<Box> findExpiringSoon() {
        LocalDate endDate = LocalDate.now().plusDays(7);
        return boxRepository.findByExpirationDateBetween(LocalDate.now(), endDate)
                .stream()
                .map(boxRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find boxes by expiration date before given date
     */
    @Transactional(readOnly = true)
    public List<Box> findByExpirationDateBefore(LocalDate date) {
        return boxRepository.findByExpirationDateBefore(date)
                .stream()
                .map(boxRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find boxes with stock
     */
    @Transactional(readOnly = true)
    public List<Box> findBoxesWithStock() {
        return boxRepository.findBoxesWithStock()
                .stream()
                .map(boxRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Find boxes out of stock
     */
    @Transactional(readOnly = true)
    public List<Box> findBoxesOutOfStock() {
        return boxRepository.findBoxesOutOfStock()
                .stream()
                .map(boxRepository::toDomain)
                .collect(Collectors.toList());
    }

    /**
     * Update box
     */
    public Box updateBox(Long id, String name, LocalDate expirationDate, Integer units) {
        Optional<BoxJpaEntity> entityOpt = boxRepository.findByIdBox(id);
        if (entityOpt.isPresent()) {
            Box box = boxRepository.toDomain(entityOpt.get());
            
            if (name != null && !name.trim().isEmpty()) {
                box.setName(name);
            }
            if (expirationDate != null) {
                box.setExpirationDate(expirationDate);
            }
            if (units != null && units >= 0) {
                box.setUnits(units);
            }
            
            return save(box);
        }
        throw new IllegalArgumentException("Box not found with id: " + id);
    }

    /**
     * Add units to box
     */
    public Box addUnits(Long id, int additionalUnits) {
        Optional<BoxJpaEntity> entityOpt = boxRepository.findByIdBox(id);
        if (entityOpt.isPresent()) {
            Box box = boxRepository.toDomain(entityOpt.get());
            box.addUnits(additionalUnits);
            return save(box);
        }
        throw new IllegalArgumentException("Box not found with id: " + id);
    }

    /**
     * Remove units from box
     */
    public Box removeUnits(Long id, int unitsToRemove) {
        Optional<BoxJpaEntity> entityOpt = boxRepository.findByIdBox(id);
        if (entityOpt.isPresent()) {
            Box box = boxRepository.toDomain(entityOpt.get());
            try {
                box.removeUnits(unitsToRemove);
                return save(box);
            } catch (RuntimeException e) {
                throw new IllegalArgumentException("Cannot remove units: " + e.getMessage());
            }
        }
        throw new IllegalArgumentException("Box not found with id: " + id);
    }

    /**
     * Delete box by ID
     */
    public void deleteById(Long id) {
        if (!boxRepository.existsById(id)) {
            throw new IllegalArgumentException("Box not found with id: " + id);
        }
        boxRepository.deleteById(id);
    }

    /**
     * Check if box exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return boxRepository.existsById(id);
    }

    /**
     * Get total units by product
     */
    @Transactional(readOnly = true)
    public Long getTotalUnitsByProduct(Long idProduct) {
        Long total = boxRepository.getTotalUnitsByProduct(idProduct);
        return total != null ? total : 0L;
    }

    /**
     * Find boxes with stock by product
     */
    @Transactional(readOnly = true)
    public List<Box> findBoxesWithStockByProduct(Long idProduct) {
        return boxRepository.findBoxesWithStockByProduct(idProduct)
                .stream()
                .map(boxRepository::toDomain)
                .collect(Collectors.toList());
    }
}
