package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Role;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.RoleJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RoleRepository extends JpaRepository<RoleJpaEntity, Long> {

    // Custom query methods
    Optional<RoleJpaEntity> findByRoleName(String roleName);
    boolean existsByRoleName(String roleName);

    // Conversion methods
    default Role toDomain(RoleJpaEntity jpaEntity) {
        if (jpaEntity == null) {
            return null;
        }
        return new Role(
            jpaEntity.getIdRole(),
            jpaEntity.getRoleName(),
            jpaEntity.getCreatedAt(),
            jpaEntity.getUpdatedAt()
        );
    }

    default RoleJpaEntity toJpaEntity(Role domain) {
        if (domain == null) {
            return null;
        }
        RoleJpaEntity entity = new RoleJpaEntity();
        entity.setIdRole(domain.getIdRole());
        entity.setRoleName(domain.getRoleName());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
