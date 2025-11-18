package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.EmployeeWarehouse;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.EmployeeWarehouseJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeWarehouseRepository extends JpaRepository<EmployeeWarehouseJpaEntity, Long> {
    
    List<EmployeeWarehouseJpaEntity> findByIdUser(Long idUser);
    
    List<EmployeeWarehouseJpaEntity> findByIdWarehouse(Long idWarehouse);
    
    Optional<EmployeeWarehouseJpaEntity> findByIdUserAndIdWarehouse(Long idUser, Long idWarehouse);
    
    @Query("SELECT ew FROM EmployeeWarehouseJpaEntity ew WHERE ew.idUser = :idUser")
    List<EmployeeWarehouseJpaEntity> findWarehousesByEmployee(@Param("idUser") Long idUser);
    
    @Query("SELECT ew FROM EmployeeWarehouseJpaEntity ew WHERE ew.idWarehouse = :idWarehouse")
    List<EmployeeWarehouseJpaEntity> findEmployeesByWarehouse(@Param("idWarehouse") Long idWarehouse);
    
    void deleteByIdUserAndIdWarehouse(Long idUser, Long idWarehouse);
    
    // Domain conversion methods
    default EmployeeWarehouse toDomain(EmployeeWarehouseJpaEntity entity) {
        if (entity == null) return null;
        
        return new EmployeeWarehouse(
            entity.getIdEmployeeWarehouse(),
            entity.getIdUser(),
            entity.getIdWarehouse(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    default EmployeeWarehouseJpaEntity toEntity(EmployeeWarehouse domain) {
        if (domain == null) return null;
        
        EmployeeWarehouseJpaEntity entity = new EmployeeWarehouseJpaEntity();
        entity.setIdEmployeeWarehouse(domain.getIdEmployeeWarehouse());
        entity.setIdUser(domain.getIdUser());
        entity.setIdWarehouse(domain.getIdWarehouse());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        
        return entity;
    }
}
