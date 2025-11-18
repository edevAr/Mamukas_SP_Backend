package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.RolePermission;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.RolePermissionJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RolePermissionRepository extends JpaRepository<RolePermissionJpaEntity, Long> {

    // Custom query methods
    List<RolePermissionJpaEntity> findByIdRole(Long idRole);
    List<RolePermissionJpaEntity> findByIdPermission(Long idPermission);
    Optional<RolePermissionJpaEntity> findByIdRoleAndIdPermission(Long idRole, Long idPermission);
    boolean existsByIdRoleAndIdPermission(Long idRole, Long idPermission);

    // Delete methods
    void deleteByIdRole(Long idRole);
    void deleteByIdPermission(Long idPermission);
    void deleteByIdRoleAndIdPermission(Long idRole, Long idPermission);

    // Conversion methods
    default RolePermission toDomain(RolePermissionJpaEntity jpaEntity) {
        if (jpaEntity == null) {
            return null;
        }
        return new RolePermission(
            jpaEntity.getIdRolePermission(),
            jpaEntity.getIdRole(),
            jpaEntity.getIdPermission(),
            jpaEntity.getCreatedAt(),
            jpaEntity.getUpdatedAt()
        );
    }

    default RolePermissionJpaEntity toJpaEntity(RolePermission domain) {
        if (domain == null) {
            return null;
        }
        RolePermissionJpaEntity entity = new RolePermissionJpaEntity();
        entity.setIdRolePermission(domain.getIdRolePermission());
        entity.setIdRole(domain.getIdRole());
        entity.setIdPermission(domain.getIdPermission());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
