package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Warehouse;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.WarehouseJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WarehouseRepository extends JpaRepository<WarehouseJpaEntity, Long> {
    
    List<WarehouseJpaEntity> findByStatus(String status);
    
    @Query("SELECT w FROM WarehouseJpaEntity w WHERE w.address LIKE %:address%")
    List<WarehouseJpaEntity> findByAddressContaining(@Param("address") String address);
    
    Optional<WarehouseJpaEntity> findByIdWarehouse(Long idWarehouse);
    
    // Domain conversion methods
    default Warehouse toDomain(WarehouseJpaEntity entity) {
        if (entity == null) return null;
        
        return new Warehouse(
            entity.getIdWarehouse(),
            entity.getAddress(),
            entity.getStatus(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    default WarehouseJpaEntity toEntity(Warehouse domain) {
        if (domain == null) return null;
        
        WarehouseJpaEntity entity = new WarehouseJpaEntity();
        entity.setIdWarehouse(domain.getIdWarehouse());
        entity.setAddress(domain.getAddress());
        entity.setStatus(domain.getStatus());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        
        return entity;
    }
}
