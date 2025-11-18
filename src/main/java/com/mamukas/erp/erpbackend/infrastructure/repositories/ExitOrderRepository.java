package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.ExitOrderJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ExitOrderRepository extends JpaRepository<ExitOrderJpaEntity, Long> {
    
    @Query("SELECT e FROM ExitOrderJpaEntity e WHERE e.idCustomer = :idCustomer")
    List<ExitOrderJpaEntity> findByIdCustomer(@Param("idCustomer") Long idCustomer);
    
    @Query("SELECT e FROM ExitOrderJpaEntity e WHERE e.status = :status")
    List<ExitOrderJpaEntity> findByStatus(@Param("status") String status);
    
    @Query("SELECT e FROM ExitOrderJpaEntity e WHERE e.date = :date")
    List<ExitOrderJpaEntity> findByDate(@Param("date") LocalDate date);
    
    @Query("SELECT e FROM ExitOrderJpaEntity e WHERE e.date BETWEEN :startDate AND :endDate")
    List<ExitOrderJpaEntity> findByDateBetween(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT e FROM ExitOrderJpaEntity e WHERE e.idCustomer = :idCustomer AND e.status = :status")
    List<ExitOrderJpaEntity> findByIdCustomerAndStatus(@Param("idCustomer") Long idCustomer, @Param("status") String status);
    
    @Query("SELECT e FROM ExitOrderJpaEntity e WHERE e.status = :status AND e.date BETWEEN :startDate AND :endDate")
    List<ExitOrderJpaEntity> findByStatusAndDateBetween(@Param("status") String status, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT COUNT(e) FROM ExitOrderJpaEntity e WHERE e.idCustomer = :idCustomer")
    long countByIdCustomer(@Param("idCustomer") Long idCustomer);
    
    @Query("SELECT COUNT(e) FROM ExitOrderJpaEntity e WHERE e.status = :status")
    long countByStatus(@Param("status") String status);
}
