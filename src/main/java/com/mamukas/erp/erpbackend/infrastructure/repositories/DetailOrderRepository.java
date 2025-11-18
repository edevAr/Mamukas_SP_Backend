package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.DetailOrderJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface DetailOrderRepository extends JpaRepository<DetailOrderJpaEntity, Long> {
    
    @Query("SELECT d FROM DetailOrderJpaEntity d WHERE d.idOrder = :idOrder")
    List<DetailOrderJpaEntity> findByIdOrder(@Param("idOrder") Long idOrder);
    
    @Query("SELECT d FROM DetailOrderJpaEntity d WHERE d.idProduct = :idProduct")
    List<DetailOrderJpaEntity> findByIdProduct(@Param("idProduct") Long idProduct);
    
    @Query("SELECT d FROM DetailOrderJpaEntity d WHERE d.amount >= :minAmount")
    List<DetailOrderJpaEntity> findByAmountGreaterThanEqual(@Param("minAmount") BigDecimal minAmount);
    
    @Query("SELECT d FROM DetailOrderJpaEntity d WHERE d.amount <= :maxAmount")
    List<DetailOrderJpaEntity> findByAmountLessThanEqual(@Param("maxAmount") BigDecimal maxAmount);
    
    @Query("SELECT d FROM DetailOrderJpaEntity d WHERE d.amount BETWEEN :minAmount AND :maxAmount")
    List<DetailOrderJpaEntity> findByAmountBetween(@Param("minAmount") BigDecimal minAmount, @Param("maxAmount") BigDecimal maxAmount);
    
    @Query("SELECT SUM(d.amount) FROM DetailOrderJpaEntity d WHERE d.idOrder = :idOrder")
    BigDecimal sumAmountByIdOrder(@Param("idOrder") Long idOrder);
    
    @Query("SELECT COUNT(d) FROM DetailOrderJpaEntity d WHERE d.idOrder = :idOrder")
    long countByIdOrder(@Param("idOrder") Long idOrder);
    
    @Query("SELECT COUNT(d) FROM DetailOrderJpaEntity d WHERE d.idProduct = :idProduct")
    long countByIdProduct(@Param("idProduct") Long idProduct);
    
    @Query("SELECT SUM(d.amount) FROM DetailOrderJpaEntity d WHERE d.idProduct = :idProduct")
    BigDecimal sumAmountByIdProduct(@Param("idProduct") Long idProduct);
}
