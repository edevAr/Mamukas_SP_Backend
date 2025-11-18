package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.request.EntryOrderRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.EntryOrderResponseDto;
import com.mamukas.erp.erpbackend.domain.entities.EntryOrder;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.EntryOrderJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.EntryOrderRepository;
import com.mamukas.erp.erpbackend.infrastructure.repositories.ProviderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class EntryOrderService {
    
    @Autowired
    private EntryOrderRepository entryOrderRepository;
    
    @Autowired
    private ProviderRepository providerRepository;
    
    // Create a new entry order
    public EntryOrderResponseDto create(EntryOrderRequestDto request) {
        // Validate provider exists
        if (!providerRepository.existsById(request.getIdProvider())) {
            throw new RuntimeException("Provider not found with ID: " + request.getIdProvider());
        }
        
        EntryOrder domain = new EntryOrder(
            request.getIdProvider(),
            request.getDate(),
            request.getStatus()
        );
        
        EntryOrderJpaEntity jpaEntity = convertToJpaEntity(domain);
        EntryOrderJpaEntity savedEntity = entryOrderRepository.save(jpaEntity);
        
        return convertToResponseDto(savedEntity);
    }
    
    // Get entry order by ID
    public Optional<EntryOrderResponseDto> findById(Long id) {
        Optional<EntryOrderJpaEntity> entity = entryOrderRepository.findById(id);
        return entity.map(this::convertToResponseDto);
    }
    
    // Get all entry orders
    public List<EntryOrderResponseDto> findAll() {
        List<EntryOrderJpaEntity> entities = entryOrderRepository.findAll();
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Get entry orders by provider ID
    public List<EntryOrderResponseDto> findByIdProvider(Long idProvider) {
        List<EntryOrderJpaEntity> entities = entryOrderRepository.findByIdProvider(idProvider);
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Get entry orders by status
    public List<EntryOrderResponseDto> findByStatus(String status) {
        List<EntryOrderJpaEntity> entities = entryOrderRepository.findByStatus(status);
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Get entry orders by date range
    public List<EntryOrderResponseDto> findByDateRange(LocalDate startDate, LocalDate endDate) {
        List<EntryOrderJpaEntity> entities = entryOrderRepository.findByDateBetween(startDate, endDate);
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Update entry order
    public Optional<EntryOrderResponseDto> update(Long id, EntryOrderRequestDto request) {
        Optional<EntryOrderJpaEntity> existingEntity = entryOrderRepository.findById(id);
        
        if (existingEntity.isPresent()) {
            // Validate provider exists if changing provider
            if (!providerRepository.existsById(request.getIdProvider())) {
                throw new RuntimeException("Provider not found with ID: " + request.getIdProvider());
            }
            
            EntryOrderJpaEntity entity = existingEntity.get();
            entity.setIdProvider(request.getIdProvider());
            entity.setDate(request.getDate());
            entity.setStatus(request.getStatus());
            
            EntryOrderJpaEntity updatedEntity = entryOrderRepository.save(entity);
            return Optional.of(convertToResponseDto(updatedEntity));
        }
        
        return Optional.empty();
    }
    
    // Update status only
    public Optional<EntryOrderResponseDto> updateStatus(Long id, String status) {
        Optional<EntryOrderJpaEntity> existingEntity = entryOrderRepository.findById(id);
        
        if (existingEntity.isPresent()) {
            EntryOrderJpaEntity entity = existingEntity.get();
            entity.setStatus(status);
            
            EntryOrderJpaEntity updatedEntity = entryOrderRepository.save(entity);
            return Optional.of(convertToResponseDto(updatedEntity));
        }
        
        return Optional.empty();
    }
    
    // Delete entry order
    public boolean delete(Long id) {
        if (entryOrderRepository.existsById(id)) {
            entryOrderRepository.deleteById(id);
            return true;
        }
        return false;
    }
    
    // Get count by provider
    public long getCountByProvider(Long idProvider) {
        return entryOrderRepository.countByIdProvider(idProvider);
    }
    
    // Get count by status
    public long getCountByStatus(String status) {
        return entryOrderRepository.countByStatus(status);
    }
    
    // Convert domain entity to JPA entity
    private EntryOrderJpaEntity convertToJpaEntity(EntryOrder domain) {
        return new EntryOrderJpaEntity(
            domain.getIdOrder(),
            domain.getIdProvider(),
            domain.getDate(),
            domain.getStatus(),
            null,
            null
        );
    }
    
    // Convert JPA entity to response DTO
    private EntryOrderResponseDto convertToResponseDto(EntryOrderJpaEntity entity) {
        return new EntryOrderResponseDto(
            entity.getIdOrder(),
            entity.getIdProvider(),
            entity.getDate(),
            entity.getStatus(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    // Convert JPA entity to domain entity
    private EntryOrder convertToDomain(EntryOrderJpaEntity entity) {
        return new EntryOrder(
            entity.getIdOrder(),
            entity.getIdProvider(),
            entity.getDate(),
            entity.getStatus(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
}
