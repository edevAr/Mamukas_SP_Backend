package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Permission;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.PermissionJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PermissionRepository extends JpaRepository<PermissionJpaEntity, Long> {

    // Custom query methods
    Optional<PermissionJpaEntity> findByName(String name);
    boolean existsByName(String name);
    List<PermissionJpaEntity> findByStatus(Boolean status);

    // Conversion methods
    default Permission toDomain(PermissionJpaEntity jpaEntity) {
        if (jpaEntity == null) {
            return null;
        }
        return new Permission(
            jpaEntity.getIdPermission(),
            jpaEntity.getName(),
            jpaEntity.getStatus(),
            jpaEntity.getCreatedAt(),
            jpaEntity.getUpdatedAt()
        );
    }

    default PermissionJpaEntity toJpaEntity(Permission domain) {
        if (domain == null) {
            return null;
        }
        PermissionJpaEntity entity = new PermissionJpaEntity();
        entity.setIdPermission(domain.getIdPermission());
        entity.setName(domain.getName());
        entity.setStatus(domain.getStatus());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
