package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.request.SaleRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.SaleResponseDto;
import com.mamukas.erp.erpbackend.domain.entities.Sale;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.SaleJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.SaleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class SaleService {

    private final SaleRepository saleRepository;

    public SaleService(SaleRepository saleRepository) {
        this.saleRepository = saleRepository;
    }

    /**
     * Create a new sale
     */
    public SaleResponseDto createSale(SaleRequestDto request) {
        // Create domain entity
        Sale sale = new Sale(
                request.getIdProduct(),
                request.getIdCustomer(),
                request.getAmount(),
                request.getSubtotal(),
                request.getDiscount()
        );
        
        // Set custom date if provided
        if (request.getDate() != null) {
            sale.setDate(request.getDate());
        }
        
        // Save sale
        Sale savedSale = save(sale);
        
        return mapToResponseDto(savedSale);
    }

    /**
     * Get all sales
     */
    @Transactional(readOnly = true)
    public List<SaleResponseDto> getAllSales() {
        return saleRepository.findAll()
                .stream()
                .map(saleRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get sale by ID
     */
    @Transactional(readOnly = true)
    public SaleResponseDto getSaleById(Long id) {
        return saleRepository.findById(id)
                .map(saleRepository::toDomain)
                .map(this::mapToResponseDto)
                .orElseThrow(() -> new IllegalArgumentException("Venta con ID " + id + " no encontrada"));
    }

    /**
     * Update a sale
     */
    public SaleResponseDto updateSale(Long id, SaleRequestDto request) {
        Sale existingSale = saleRepository.findById(id)
                .map(saleRepository::toDomain)
                .orElseThrow(() -> new IllegalArgumentException("Venta con ID " + id + " no encontrada"));
        
        // Update fields
        if (request.getDate() != null) {
            existingSale.setDate(request.getDate());
        }
        existingSale.setIdProduct(request.getIdProduct());
        existingSale.setIdCustomer(request.getIdCustomer());
        existingSale.setAmount(request.getAmount());
        existingSale.setSubtotal(request.getSubtotal());
        existingSale.setDiscount(request.getDiscount());
        
        Sale savedSale = save(existingSale);
        
        return mapToResponseDto(savedSale);
    }

    /**
     * Delete a sale
     */
    public boolean deleteSale(Long id) {
        if (!saleRepository.existsById(id)) {
            throw new IllegalArgumentException("Venta con ID " + id + " no encontrada");
        }
        
        saleRepository.deleteById(id);
        return true;
    }

    /**
     * Get sales by product
     */
    @Transactional(readOnly = true)
    public List<SaleResponseDto> getSalesByProduct(Long idProduct) {
        return saleRepository.findByIdProduct(idProduct)
                .stream()
                .map(saleRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get sales by customer
     */
    @Transactional(readOnly = true)
    public List<SaleResponseDto> getSalesByCustomer(Long idCustomer) {
        return saleRepository.findByIdCustomer(idCustomer)
                .stream()
                .map(saleRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get sales by date range
     */
    @Transactional(readOnly = true)
    public List<SaleResponseDto> getSalesByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return saleRepository.findByDateBetween(startDate, endDate)
                .stream()
                .map(saleRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get sales by total range
     */
    @Transactional(readOnly = true)
    public List<SaleResponseDto> getSalesByTotalRange(BigDecimal minTotal, BigDecimal maxTotal) {
        return saleRepository.findByTotalBetween(minTotal, maxTotal)
                .stream()
                .map(saleRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get sales by customer and date range
     */
    @Transactional(readOnly = true)
    public List<SaleResponseDto> getSalesByCustomerAndDateRange(Long idCustomer, LocalDateTime startDate, LocalDateTime endDate) {
        return saleRepository.findByCustomerAndDateRange(idCustomer, startDate, endDate)
                .stream()
                .map(saleRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get sales by product and date range
     */
    @Transactional(readOnly = true)
    public List<SaleResponseDto> getSalesByProductAndDateRange(Long idProduct, LocalDateTime startDate, LocalDateTime endDate) {
        return saleRepository.findByProductAndDateRange(idProduct, startDate, endDate)
                .stream()
                .map(saleRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get total sales by date range
     */
    @Transactional(readOnly = true)
    public BigDecimal getTotalSalesByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        BigDecimal total = saleRepository.getTotalSalesByDateRange(startDate, endDate);
        return total != null ? total : BigDecimal.ZERO;
    }

    /**
     * Get total sales by customer
     */
    @Transactional(readOnly = true)
    public BigDecimal getTotalSalesByCustomer(Long idCustomer) {
        BigDecimal total = saleRepository.getTotalSalesByCustomer(idCustomer);
        return total != null ? total : BigDecimal.ZERO;
    }

    /**
     * Apply discount to sale
     */
    public SaleResponseDto applyDiscount(Long id, BigDecimal discount) {
        Sale sale = saleRepository.findById(id)
                .map(saleRepository::toDomain)
                .orElseThrow(() -> new IllegalArgumentException("Venta con ID " + id + " no encontrada"));
        
        sale.applyDiscount(discount);
        Sale savedSale = save(sale);
        
        return mapToResponseDto(savedSale);
    }

    /**
     * Check if sale exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return saleRepository.existsById(id);
    }

    /**
     * Get sale count
     */
    @Transactional(readOnly = true)
    public long getSaleCount() {
        return saleRepository.count();
    }

    /**
     * Find sale by ID (optional)
     */
    @Transactional(readOnly = true)
    public java.util.Optional<Sale> findById(Long id) {
        return saleRepository.findById(id).map(saleRepository::toDomain);
    }

    /**
     * Save sale (for direct domain operations)
     */
    public Sale save(Sale sale) {
        SaleJpaEntity jpaEntity = saleRepository.toJpaEntity(sale);
        SaleJpaEntity saved = saleRepository.save(jpaEntity);
        return saleRepository.toDomain(saved);
    }

    /**
     * Map to response DTO
     */
    private SaleResponseDto mapToResponseDto(Sale sale) {
        return new SaleResponseDto(
                sale.getIdSale(),
                sale.getDate(),
                sale.getIdProduct(),
                sale.getIdCustomer(),
                sale.getAmount(),
                sale.getSubtotal(),
                sale.getDiscount(),
                sale.getTotal(),
                sale.getCreatedAt(),
                sale.getUpdatedAt()
        );
    }
}
