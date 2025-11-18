package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Product;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.ProductJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<ProductJpaEntity, Long> {
    
    // Custom query methods
    Optional<ProductJpaEntity> findByIdProduct(Long idProduct);
    
    Optional<ProductJpaEntity> findByName(String name);
    
    List<ProductJpaEntity> findByStatus(String status);
    
    List<ProductJpaEntity> findByNameContaining(String name);
    
    List<ProductJpaEntity> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice);
    
    List<ProductJpaEntity> findByExpirationDateBefore(LocalDate date);
    
    List<ProductJpaEntity> findByExpirationDateAfter(LocalDate date);
    
    @Query("SELECT p FROM ProductJpaEntity p WHERE p.status = 'Active'")
    List<ProductJpaEntity> findActiveProducts();
    
    @Query("SELECT p FROM ProductJpaEntity p WHERE p.status = 'Inactive'")
    List<ProductJpaEntity> findInactiveProducts();
    
    @Query("SELECT p FROM ProductJpaEntity p WHERE p.expirationDate BETWEEN :startDate AND :endDate")
    List<ProductJpaEntity> findByExpirationDateBetween(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT p FROM ProductJpaEntity p WHERE p.price <= :maxPrice AND p.status = 'Active'")
    List<ProductJpaEntity> findActiveProductsByMaxPrice(@Param("maxPrice") BigDecimal maxPrice);
    
    @Query("SELECT COUNT(p) FROM ProductJpaEntity p WHERE p.status = :status")
    long countByStatus(@Param("status") String status);
    
    // Conversion methods
    default Product toDomain(ProductJpaEntity entity) {
        return new Product(
            entity.getIdProduct(),
            entity.getName(),
            entity.getStatus(),
            entity.getPrice(),
            entity.getExpirationDate(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    default ProductJpaEntity toEntity(Product domain) {
        ProductJpaEntity entity = new ProductJpaEntity();
        entity.setIdProduct(domain.getIdProduct());
        entity.setName(domain.getName());
        entity.setStatus(domain.getStatus());
        entity.setPrice(domain.getPrice());
        entity.setExpirationDate(domain.getExpirationDate());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
