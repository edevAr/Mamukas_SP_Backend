package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Sale;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.SaleJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SaleRepository extends JpaRepository<SaleJpaEntity, Long> {

    // Custom query methods
    List<SaleJpaEntity> findByIdProduct(Long idProduct);
    List<SaleJpaEntity> findByIdCustomer(Long idCustomer);
    List<SaleJpaEntity> findByDateBetween(LocalDateTime startDate, LocalDateTime endDate);
    
    @Query("SELECT s FROM SaleJpaEntity s WHERE s.total BETWEEN :minTotal AND :maxTotal")
    List<SaleJpaEntity> findByTotalBetween(@Param("minTotal") BigDecimal minTotal, @Param("maxTotal") BigDecimal maxTotal);
    
    @Query("SELECT s FROM SaleJpaEntity s WHERE s.idCustomer = :idCustomer AND s.date BETWEEN :startDate AND :endDate")
    List<SaleJpaEntity> findByCustomerAndDateRange(@Param("idCustomer") Long idCustomer, 
                                                   @Param("startDate") LocalDateTime startDate, 
                                                   @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT s FROM SaleJpaEntity s WHERE s.idProduct = :idProduct AND s.date BETWEEN :startDate AND :endDate")
    List<SaleJpaEntity> findByProductAndDateRange(@Param("idProduct") Long idProduct, 
                                                  @Param("startDate") LocalDateTime startDate, 
                                                  @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT SUM(s.total) FROM SaleJpaEntity s WHERE s.date BETWEEN :startDate AND :endDate")
    BigDecimal getTotalSalesByDateRange(@Param("startDate") LocalDateTime startDate, 
                                       @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT SUM(s.total) FROM SaleJpaEntity s WHERE s.idCustomer = :idCustomer")
    BigDecimal getTotalSalesByCustomer(@Param("idCustomer") Long idCustomer);

    // Conversion methods
    default Sale toDomain(SaleJpaEntity jpaEntity) {
        if (jpaEntity == null) {
            return null;
        }
        return new Sale(
            jpaEntity.getIdSale(),
            jpaEntity.getDate(),
            jpaEntity.getIdProduct(),
            jpaEntity.getIdCustomer(),
            jpaEntity.getAmount(),
            jpaEntity.getSubtotal(),
            jpaEntity.getDiscount(),
            jpaEntity.getTotal(),
            jpaEntity.getCreatedAt(),
            jpaEntity.getUpdatedAt()
        );
    }

    default SaleJpaEntity toJpaEntity(Sale domain) {
        if (domain == null) {
            return null;
        }
        SaleJpaEntity entity = new SaleJpaEntity();
        entity.setIdSale(domain.getIdSale());
        entity.setDate(domain.getDate());
        entity.setIdProduct(domain.getIdProduct());
        entity.setIdCustomer(domain.getIdCustomer());
        entity.setAmount(domain.getAmount());
        entity.setSubtotal(domain.getSubtotal());
        entity.setDiscount(domain.getDiscount());
        entity.setTotal(domain.getTotal());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
