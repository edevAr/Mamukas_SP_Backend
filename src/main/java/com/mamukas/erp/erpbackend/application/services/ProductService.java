package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.domain.entities.Product;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.ProductJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class ProductService {
    
    @Autowired
    private ProductRepository productRepository;
    
    /**
     * Save product
     */
    public Product save(Product product) {
        ProductJpaEntity entity = productRepository.toEntity(product);
        ProductJpaEntity savedEntity = productRepository.save(entity);
        return productRepository.toDomain(savedEntity);
    }
    
    /**
     * Create new product
     */
    public Product createProduct(String name, String status, BigDecimal price, LocalDate expirationDate) {
        Product product = new Product(name, status, price, expirationDate);
        return save(product);
    }
    
    /**
     * Find product by ID
     */
    @Transactional(readOnly = true)
    public Optional<Product> findById(Long id) {
        Optional<ProductJpaEntity> entity = productRepository.findByIdProduct(id);
        return entity.map(productRepository::toDomain);
    }
    
    /**
     * Find all products
     */
    @Transactional(readOnly = true)
    public List<Product> findAll() {
        return productRepository.findAll()
                .stream()
                .map(productRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find products by status
     */
    @Transactional(readOnly = true)
    public List<Product> findByStatus(String status) {
        return productRepository.findByStatus(status)
                .stream()
                .map(productRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find active products
     */
    @Transactional(readOnly = true)
    public List<Product> findActiveProducts() {
        return productRepository.findActiveProducts()
                .stream()
                .map(productRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find inactive products
     */
    @Transactional(readOnly = true)
    public List<Product> findInactiveProducts() {
        return productRepository.findInactiveProducts()
                .stream()
                .map(productRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find products by name containing text
     */
    @Transactional(readOnly = true)
    public List<Product> findByNameContaining(String name) {
        return productRepository.findByNameContaining(name)
                .stream()
                .map(productRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find product by exact name
     */
    @Transactional(readOnly = true)
    public Optional<Product> findByName(String name) {
        Optional<ProductJpaEntity> entity = productRepository.findByName(name);
        return entity.map(productRepository::toDomain);
    }
    
    /**
     * Find products by price range
     */
    @Transactional(readOnly = true)
    public List<Product> findByPriceRange(BigDecimal minPrice, BigDecimal maxPrice) {
        return productRepository.findByPriceBetween(minPrice, maxPrice)
                .stream()
                .map(productRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find products by max price (active only)
     */
    @Transactional(readOnly = true)
    public List<Product> findActiveProductsByMaxPrice(BigDecimal maxPrice) {
        return productRepository.findActiveProductsByMaxPrice(maxPrice)
                .stream()
                .map(productRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find products expiring before a date
     */
    @Transactional(readOnly = true)
    public List<Product> findExpiringBefore(LocalDate date) {
        return productRepository.findByExpirationDateBefore(date)
                .stream()
                .map(productRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find products expiring after a date
     */
    @Transactional(readOnly = true)
    public List<Product> findExpiringAfter(LocalDate date) {
        return productRepository.findByExpirationDateAfter(date)
                .stream()
                .map(productRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find products expiring in date range
     */
    @Transactional(readOnly = true)
    public List<Product> findExpiringBetween(LocalDate startDate, LocalDate endDate) {
        return productRepository.findByExpirationDateBetween(startDate, endDate)
                .stream()
                .map(productRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find products expiring soon (within specified days)
     */
    @Transactional(readOnly = true)
    public List<Product> findExpiringSoon(int days) {
        LocalDate futureDate = LocalDate.now().plusDays(days);
        return findExpiringBefore(futureDate);
    }
    
    /**
     * Update product
     */
    public Product updateProduct(Long id, String name, String status, BigDecimal price, LocalDate expirationDate) {
        Optional<ProductJpaEntity> entityOpt = productRepository.findByIdProduct(id);
        if (entityOpt.isPresent()) {
            Product product = productRepository.toDomain(entityOpt.get());
            product.setName(name);
            product.setStatus(status);
            product.setPrice(price);
            product.setExpirationDate(expirationDate);
            return save(product);
        }
        throw new RuntimeException("Product not found with id: " + id);
    }
    
    /**
     * Activate product
     */
    public Product activateProduct(Long id) {
        Optional<ProductJpaEntity> entityOpt = productRepository.findByIdProduct(id);
        if (entityOpt.isPresent()) {
            Product product = productRepository.toDomain(entityOpt.get());
            product.activate();
            return save(product);
        }
        throw new RuntimeException("Product not found with id: " + id);
    }
    
    /**
     * Deactivate product
     */
    public Product deactivateProduct(Long id) {
        Optional<ProductJpaEntity> entityOpt = productRepository.findByIdProduct(id);
        if (entityOpt.isPresent()) {
            Product product = productRepository.toDomain(entityOpt.get());
            product.deactivate();
            return save(product);
        }
        throw new RuntimeException("Product not found with id: " + id);
    }
    
    /**
     * Count products by status
     */
    @Transactional(readOnly = true)
    public long countByStatus(String status) {
        return productRepository.countByStatus(status);
    }
    
    /**
     * Check if product exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return productRepository.existsById(id);
    }
    
    /**
     * Delete product
     */
    public void deleteProduct(Long id) {
        if (productRepository.existsById(id)) {
            productRepository.deleteById(id);
        } else {
            throw new RuntimeException("Product not found with id: " + id);
        }
    }
}
