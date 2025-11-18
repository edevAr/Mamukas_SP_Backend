package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.EmployeeStore;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.EmployeeStoreJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeStoreRepository extends JpaRepository<EmployeeStoreJpaEntity, Long> {

    // Custom query methods
    List<EmployeeStoreJpaEntity> findByIdEmployee(Long idEmployee);
    List<EmployeeStoreJpaEntity> findByIdStore(Long idStore);
    Optional<EmployeeStoreJpaEntity> findByIdEmployeeAndIdStore(Long idEmployee, Long idStore);
    boolean existsByIdEmployeeAndIdStore(Long idEmployee, Long idStore);

    // Delete methods
    void deleteByIdEmployee(Long idEmployee);
    void deleteByIdStore(Long idStore);
    void deleteByIdEmployeeAndIdStore(Long idEmployee, Long idStore);

    // Conversion methods
    default EmployeeStore toDomain(EmployeeStoreJpaEntity jpaEntity) {
        if (jpaEntity == null) {
            return null;
        }
        return new EmployeeStore(
            jpaEntity.getIdEmployeeStore(),
            jpaEntity.getIdEmployee(),
            jpaEntity.getIdStore(),
            jpaEntity.getCreatedAt(),
            jpaEntity.getUpdatedAt()
        );
    }

    default EmployeeStoreJpaEntity toJpaEntity(EmployeeStore domain) {
        if (domain == null) {
            return null;
        }
        EmployeeStoreJpaEntity entity = new EmployeeStoreJpaEntity();
        entity.setIdEmployeeStore(domain.getIdEmployeeStore());
        entity.setIdEmployee(domain.getIdEmployee());
        entity.setIdStore(domain.getIdStore());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
