package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Box;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.BoxJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface BoxRepository extends JpaRepository<BoxJpaEntity, Long> {
    
    // Custom query methods
    Optional<BoxJpaEntity> findByIdBox(Long idBox);
    
    List<BoxJpaEntity> findByIdProduct(Long idProduct);
    
    List<BoxJpaEntity> findByName(String name);
    
    List<BoxJpaEntity> findByNameContaining(String name);
    
    List<BoxJpaEntity> findByExpirationDateBefore(LocalDate date);
    
    List<BoxJpaEntity> findByExpirationDateAfter(LocalDate date);
    
    List<BoxJpaEntity> findByUnitsGreaterThan(Integer units);
    
    @Query("SELECT b FROM BoxJpaEntity b WHERE b.expirationDate BETWEEN :startDate AND :endDate")
    List<BoxJpaEntity> findByExpirationDateBetween(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT b FROM BoxJpaEntity b WHERE b.units > 0")
    List<BoxJpaEntity> findBoxesWithStock();
    
    @Query("SELECT b FROM BoxJpaEntity b WHERE b.units <= 0")
    List<BoxJpaEntity> findBoxesOutOfStock();
    
    @Query("SELECT b FROM BoxJpaEntity b WHERE b.idProduct = :idProduct AND b.units > 0")
    List<BoxJpaEntity> findBoxesWithStockByProduct(@Param("idProduct") Long idProduct);
    
    @Query("SELECT SUM(b.units) FROM BoxJpaEntity b WHERE b.idProduct = :idProduct")
    Long getTotalUnitsByProduct(@Param("idProduct") Long idProduct);
    
    // Conversion methods
    default Box toDomain(BoxJpaEntity entity) {
        return new Box(
            entity.getIdBox(),
            entity.getIdProduct(),
            entity.getName(),
            entity.getExpirationDate(),
            entity.getUnits(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    default BoxJpaEntity toEntity(Box domain) {
        BoxJpaEntity entity = new BoxJpaEntity();
        entity.setIdBox(domain.getIdBox());
        entity.setIdProduct(domain.getIdProduct());
        entity.setName(domain.getName());
        entity.setExpirationDate(domain.getExpirationDate());
        entity.setUnits(domain.getUnits());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
