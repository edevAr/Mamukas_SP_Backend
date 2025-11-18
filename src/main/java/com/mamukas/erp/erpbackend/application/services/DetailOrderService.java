package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.request.DetailOrderRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.DetailOrderResponseDto;
import com.mamukas.erp.erpbackend.domain.entities.DetailOrder;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.DetailOrderJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.DetailOrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class DetailOrderService {
    
    @Autowired
    private DetailOrderRepository detailOrderRepository;
    
    // Create a new detail order
    public DetailOrderResponseDto create(DetailOrderRequestDto request) {
        // Validate product exists
        // TODO: Add product validation when ProductRepository is available
        
        DetailOrder domain = new DetailOrder(
            request.getIdOrder(),
            request.getIdProduct(),
            request.getAmount()
        );
        
        DetailOrderJpaEntity jpaEntity = convertToJpaEntity(domain);
        DetailOrderJpaEntity savedEntity = detailOrderRepository.save(jpaEntity);
        
        return convertToResponseDto(savedEntity);
    }
    
    // Get detail order by ID
    public Optional<DetailOrderResponseDto> findById(Long id) {
        Optional<DetailOrderJpaEntity> entity = detailOrderRepository.findById(id);
        return entity.map(this::convertToResponseDto);
    }
    
    // Get all detail orders
    public List<DetailOrderResponseDto> findAll() {
        List<DetailOrderJpaEntity> entities = detailOrderRepository.findAll();
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Get detail orders by order ID
    public List<DetailOrderResponseDto> findByIdOrder(Long idOrder) {
        List<DetailOrderJpaEntity> entities = detailOrderRepository.findByIdOrder(idOrder);
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Get detail orders by product ID
    public List<DetailOrderResponseDto> findByIdProduct(Long idProduct) {
        List<DetailOrderJpaEntity> entities = detailOrderRepository.findByIdProduct(idProduct);
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Get detail orders by amount range
    public List<DetailOrderResponseDto> findByAmountRange(BigDecimal minAmount, BigDecimal maxAmount) {
        List<DetailOrderJpaEntity> entities = detailOrderRepository.findByAmountBetween(minAmount, maxAmount);
        return entities.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }
    
    // Update detail order
    public Optional<DetailOrderResponseDto> update(Long id, DetailOrderRequestDto request) {
        Optional<DetailOrderJpaEntity> existingEntity = detailOrderRepository.findById(id);
        
        if (existingEntity.isPresent()) {
            DetailOrderJpaEntity entity = existingEntity.get();
            entity.setIdOrder(request.getIdOrder());
            entity.setIdProduct(request.getIdProduct());
            entity.setAmount(request.getAmount());
            
            DetailOrderJpaEntity updatedEntity = detailOrderRepository.save(entity);
            return Optional.of(convertToResponseDto(updatedEntity));
        }
        
        return Optional.empty();
    }
    
    // Delete detail order
    public boolean delete(Long id) {
        if (detailOrderRepository.existsById(id)) {
            detailOrderRepository.deleteById(id);
            return true;
        }
        return false;
    }
    
    // Get total amount for an order
    public BigDecimal getTotalAmountByOrder(Long idOrder) {
        BigDecimal total = detailOrderRepository.sumAmountByIdOrder(idOrder);
        return total != null ? total : BigDecimal.ZERO;
    }
    
    // Get count of detail orders for an order
    public long getCountByOrder(Long idOrder) {
        return detailOrderRepository.countByIdOrder(idOrder);
    }
    
    // Get count of detail orders for a product
    public long getCountByProduct(Long idProduct) {
        return detailOrderRepository.countByIdProduct(idProduct);
    }
    
    // Get total amount for a product
    public BigDecimal getTotalAmountByProduct(Long idProduct) {
        BigDecimal total = detailOrderRepository.sumAmountByIdProduct(idProduct);
        return total != null ? total : BigDecimal.ZERO;
    }
    
    // Convert domain entity to JPA entity
    private DetailOrderJpaEntity convertToJpaEntity(DetailOrder domain) {
        return new DetailOrderJpaEntity(
            domain.getIdDetail(),
            domain.getIdOrder(),
            domain.getIdProduct(),
            domain.getAmount(),
            null,
            null
        );
    }
    
    // Convert JPA entity to response DTO
    private DetailOrderResponseDto convertToResponseDto(DetailOrderJpaEntity entity) {
        return new DetailOrderResponseDto(
            entity.getIdDetail(),
            entity.getIdOrder(),
            entity.getIdProduct(),
            entity.getAmount(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    // Convert JPA entity to domain entity
    private DetailOrder convertToDomain(DetailOrderJpaEntity entity) {
        return new DetailOrder(
            entity.getIdDetail(),
            entity.getIdOrder(),
            entity.getIdProduct(),
            entity.getAmount(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
}
