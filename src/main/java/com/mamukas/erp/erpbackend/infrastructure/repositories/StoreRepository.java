package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Store;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.StoreJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StoreRepository extends JpaRepository<StoreJpaEntity, Long> {
    
    List<StoreJpaEntity> findByStatus(String status);
    
    @Query("SELECT s FROM StoreJpaEntity s WHERE s.name LIKE %:name%")
    List<StoreJpaEntity> findByNameContaining(@Param("name") String name);
    
    @Query("SELECT s FROM StoreJpaEntity s WHERE s.address LIKE %:address%")
    List<StoreJpaEntity> findByAddressContaining(@Param("address") String address);
    
    Optional<StoreJpaEntity> findByIdStore(Long idStore);
    
    Optional<StoreJpaEntity> findByName(String name);
    
    // Domain conversion methods
    default Store toDomain(StoreJpaEntity entity) {
        if (entity == null) return null;
        
        return new Store(
            entity.getIdStore(),
            entity.getName(),
            entity.getAddress(),
            entity.getStatus(),
            entity.getBusinessHours(),
            entity.getIdCompany(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    default StoreJpaEntity toEntity(Store domain) {
        if (domain == null) return null;
        
        StoreJpaEntity entity = new StoreJpaEntity();
        entity.setIdStore(domain.getIdStore());
        entity.setName(domain.getName());
        entity.setAddress(domain.getAddress());
        entity.setStatus(domain.getStatus());
        entity.setBusinessHours(domain.getBusinessHours());
        entity.setIdCompany(domain.getIdCompany());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        
        return entity;
    }
}
