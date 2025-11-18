package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.request.ExitOrderRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.ExitOrderResponseDto;
import com.mamukas.erp.erpbackend.domain.entities.ExitOrder;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.ExitOrderJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.ExitOrderRepository;
import com.mamukas.erp.erpbackend.infrastructure.repositories.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ExitOrderService {
    
    @Autowired
    private ExitOrderRepository exitOrderRepository;
    
    @Autowired
    private CustomerRepository customerRepository;
    
    // Create a new exit order
    public ExitOrderResponseDto create(ExitOrderRequestDto request) {
        // Validate customer exists
        if (!customerRepository.existsById(request.getIdCustomer())) {
            throw new RuntimeException("Customer not found with ID: " + request.getIdCustomer());
        }
        
        ExitOrder domain = new ExitOrder(
            request.getIdCustomer(),
            request.getDate(),
            request.getStatus()
        );
        
        ExitOrderJpaEntity jpaEntity = convertToJpaEntity(domain);
        ExitOrderJpaEntity savedEntity = exitOrderRepository.save(jpaEntity);
        
        return convertToResponseDto(savedEntity);
    }
    
    // Get exit order by ID
    public Optional<ExitOrderResponseDto> findById(Long id) {
        Optional<ExitOrderJpaEntity> entity = exitOrderRepository.findById(id);
        return entity.map(this::convertToResponseDto);
    }
    
    // Get all exit orders
    public List<ExitOrderResponseDto> findAll() {
        List<ExitOrderJpaEntity> entities = exitOrderRepository.findAll();
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Get exit orders by customer ID
    public List<ExitOrderResponseDto> findByIdCustomer(Long idCustomer) {
        List<ExitOrderJpaEntity> entities = exitOrderRepository.findByIdCustomer(idCustomer);
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Get exit orders by status
    public List<ExitOrderResponseDto> findByStatus(String status) {
        List<ExitOrderJpaEntity> entities = exitOrderRepository.findByStatus(status);
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Get exit orders by date range
    public List<ExitOrderResponseDto> findByDateRange(LocalDate startDate, LocalDate endDate) {
        List<ExitOrderJpaEntity> entities = exitOrderRepository.findByDateBetween(startDate, endDate);
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Update exit order
    public Optional<ExitOrderResponseDto> update(Long id, ExitOrderRequestDto request) {
        Optional<ExitOrderJpaEntity> existingEntity = exitOrderRepository.findById(id);
        
        if (existingEntity.isPresent()) {
            // Validate customer exists if changing customer
            if (!customerRepository.existsById(request.getIdCustomer())) {
                throw new RuntimeException("Customer not found with ID: " + request.getIdCustomer());
            }
            
            ExitOrderJpaEntity entity = existingEntity.get();
            entity.setIdCustomer(request.getIdCustomer());
            entity.setDate(request.getDate());
            entity.setStatus(request.getStatus());
            
            ExitOrderJpaEntity updatedEntity = exitOrderRepository.save(entity);
            return Optional.of(convertToResponseDto(updatedEntity));
        }
        
        return Optional.empty();
    }
    
    // Update status only
    public Optional<ExitOrderResponseDto> updateStatus(Long id, String status) {
        Optional<ExitOrderJpaEntity> existingEntity = exitOrderRepository.findById(id);
        
        if (existingEntity.isPresent()) {
            ExitOrderJpaEntity entity = existingEntity.get();
            entity.setStatus(status);
            
            ExitOrderJpaEntity updatedEntity = exitOrderRepository.save(entity);
            return Optional.of(convertToResponseDto(updatedEntity));
        }
        
        return Optional.empty();
    }
    
    // Delete exit order
    public boolean delete(Long id) {
        if (exitOrderRepository.existsById(id)) {
            exitOrderRepository.deleteById(id);
            return true;
        }
        return false;
    }
    
    // Get count by customer
    public long getCountByCustomer(Long idCustomer) {
        return exitOrderRepository.countByIdCustomer(idCustomer);
    }
    
    // Get count by status
    public long getCountByStatus(String status) {
        return exitOrderRepository.countByStatus(status);
    }
    
    // Convert domain entity to JPA entity
    private ExitOrderJpaEntity convertToJpaEntity(ExitOrder domain) {
        return new ExitOrderJpaEntity(
            domain.getIdOrder(),
            domain.getIdCustomer(),
            domain.getDate(),
            domain.getStatus(),
            null,
            null
        );
    }
    
    // Convert JPA entity to response DTO
    private ExitOrderResponseDto convertToResponseDto(ExitOrderJpaEntity entity) {
        return new ExitOrderResponseDto(
            entity.getIdOrder(),
            entity.getIdCustomer(),
            entity.getDate(),
            entity.getStatus(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    // Convert JPA entity to domain entity
    private ExitOrder convertToDomain(ExitOrderJpaEntity entity) {
        return new ExitOrder(
            entity.getIdOrder(),
            entity.getIdCustomer(),
            entity.getDate(),
            entity.getStatus(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
}
