package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Pack;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.PackJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PackRepository extends JpaRepository<PackJpaEntity, Long> {
    
    // Custom query methods
    Optional<PackJpaEntity> findByIdPack(Long idPack);
    
    List<PackJpaEntity> findByIdProduct(Long idProduct);
    
    List<PackJpaEntity> findByName(String name);
    
    List<PackJpaEntity> findByNameContaining(String name);
    
    List<PackJpaEntity> findByExpirationDateBefore(LocalDate date);
    
    List<PackJpaEntity> findByExpirationDateAfter(LocalDate date);
    
    List<PackJpaEntity> findByUnitsGreaterThan(Integer units);
    
    @Query("SELECT p FROM PackJpaEntity p WHERE p.expirationDate BETWEEN :startDate AND :endDate")
    List<PackJpaEntity> findByExpirationDateBetween(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT p FROM PackJpaEntity p WHERE p.units > 0")
    List<PackJpaEntity> findPacksWithStock();
    
    @Query("SELECT p FROM PackJpaEntity p WHERE p.units <= 0")
    List<PackJpaEntity> findPacksOutOfStock();
    
    @Query("SELECT p FROM PackJpaEntity p WHERE p.idProduct = :idProduct AND p.units > 0")
    List<PackJpaEntity> findPacksWithStockByProduct(@Param("idProduct") Long idProduct);
    
    @Query("SELECT SUM(p.units) FROM PackJpaEntity p WHERE p.idProduct = :idProduct")
    Long getTotalUnitsByProduct(@Param("idProduct") Long idProduct);
    
    // Conversion methods
    default Pack toDomain(PackJpaEntity entity) {
        return new Pack(
            entity.getIdPack(),
            entity.getIdProduct(),
            entity.getName(),
            entity.getExpirationDate(),
            entity.getUnits(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    default PackJpaEntity toEntity(Pack domain) {
        PackJpaEntity entity = new PackJpaEntity();
        entity.setIdPack(domain.getIdPack());
        entity.setIdProduct(domain.getIdProduct());
        entity.setName(domain.getName());
        entity.setExpirationDate(domain.getExpirationDate());
        entity.setUnits(domain.getUnits());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
