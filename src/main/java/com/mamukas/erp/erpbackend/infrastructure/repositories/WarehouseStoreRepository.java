package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.WarehouseStore;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.WarehouseStoreJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WarehouseStoreRepository extends JpaRepository<WarehouseStoreJpaEntity, Long> {
    
    List<WarehouseStoreJpaEntity> findByIdWarehouse(Long idWarehouse);
    
    List<WarehouseStoreJpaEntity> findByIdStore(Long idStore);
    
    Optional<WarehouseStoreJpaEntity> findByIdWarehouseAndIdStore(Long idWarehouse, Long idStore);
    
    @Query("SELECT ws FROM WarehouseStoreJpaEntity ws WHERE ws.idWarehouse = :idWarehouse")
    List<WarehouseStoreJpaEntity> findStoresByWarehouse(@Param("idWarehouse") Long idWarehouse);
    
    @Query("SELECT ws FROM WarehouseStoreJpaEntity ws WHERE ws.idStore = :idStore")
    List<WarehouseStoreJpaEntity> findWarehousesByStore(@Param("idStore") Long idStore);
    
    void deleteByIdWarehouseAndIdStore(Long idWarehouse, Long idStore);
    
    // Domain conversion methods
    default WarehouseStore toDomain(WarehouseStoreJpaEntity entity) {
        if (entity == null) return null;
        
        return new WarehouseStore(
            entity.getIdWarehouseStore(),
            entity.getIdWarehouse(),
            entity.getIdStore(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    default WarehouseStoreJpaEntity toEntity(WarehouseStore domain) {
        if (domain == null) return null;
        
        WarehouseStoreJpaEntity entity = new WarehouseStoreJpaEntity();
        entity.setIdWarehouseStore(domain.getIdWarehouseStore());
        entity.setIdWarehouse(domain.getIdWarehouse());
        entity.setIdStore(domain.getIdStore());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        
        return entity;
    }
}
