package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.EntryOrderJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface EntryOrderRepository extends JpaRepository<EntryOrderJpaEntity, Long> {
    
    @Query("SELECT e FROM EntryOrderJpaEntity e WHERE e.idProvider = :idProvider")
    List<EntryOrderJpaEntity> findByIdProvider(@Param("idProvider") Long idProvider);
    
    @Query("SELECT e FROM EntryOrderJpaEntity e WHERE e.status = :status")
    List<EntryOrderJpaEntity> findByStatus(@Param("status") String status);
    
    @Query("SELECT e FROM EntryOrderJpaEntity e WHERE e.date = :date")
    List<EntryOrderJpaEntity> findByDate(@Param("date") LocalDate date);
    
    @Query("SELECT e FROM EntryOrderJpaEntity e WHERE e.date BETWEEN :startDate AND :endDate")
    List<EntryOrderJpaEntity> findByDateBetween(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT e FROM EntryOrderJpaEntity e WHERE e.idProvider = :idProvider AND e.status = :status")
    List<EntryOrderJpaEntity> findByIdProviderAndStatus(@Param("idProvider") Long idProvider, @Param("status") String status);
    
    @Query("SELECT e FROM EntryOrderJpaEntity e WHERE e.status = :status AND e.date BETWEEN :startDate AND :endDate")
    List<EntryOrderJpaEntity> findByStatusAndDateBetween(@Param("status") String status, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT COUNT(e) FROM EntryOrderJpaEntity e WHERE e.idProvider = :idProvider")
    long countByIdProvider(@Param("idProvider") Long idProvider);
    
    @Query("SELECT COUNT(e) FROM EntryOrderJpaEntity e WHERE e.status = :status")
    long countByStatus(@Param("status") String status);
}
