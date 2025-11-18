package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Company;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.CompanyJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CompanyRepository extends JpaRepository<CompanyJpaEntity, Long> {

    // Custom query methods
    Optional<CompanyJpaEntity> findByIdCompany(Long idCompany);
    List<CompanyJpaEntity> findByNameContainingIgnoreCase(String name);
    List<CompanyJpaEntity> findByAddressContainingIgnoreCase(String address);
    List<CompanyJpaEntity> findByStatus(String status);
    
    @Query("SELECT c FROM CompanyJpaEntity c WHERE c.name LIKE %:name% AND c.status = :status")
    List<CompanyJpaEntity> findByNameAndStatus(@Param("name") String name, @Param("status") String status);
    
    @Query("SELECT c FROM CompanyJpaEntity c WHERE c.address LIKE %:address% AND c.status = :status")
    List<CompanyJpaEntity> findByAddressAndStatus(@Param("address") String address, @Param("status") String status);
    
    boolean existsByName(String name);
    boolean existsByNameAndIdCompanyNot(String name, Long idCompany);

    // Conversion methods
    default Company toDomain(CompanyJpaEntity jpaEntity) {
        if (jpaEntity == null) {
            return null;
        }
        return new Company(
            jpaEntity.getIdCompany(),
            jpaEntity.getName(),
            jpaEntity.getAddress(),
            jpaEntity.getStatus(),
            jpaEntity.getBusinessHours(),
            jpaEntity.getCreatedAt(),
            jpaEntity.getUpdatedAt()
        );
    }

    default CompanyJpaEntity toJpaEntity(Company domain) {
        if (domain == null) {
            return null;
        }
        CompanyJpaEntity entity = new CompanyJpaEntity();
        entity.setIdCompany(domain.getIdCompany());
        entity.setName(domain.getName());
        entity.setAddress(domain.getAddress());
        entity.setStatus(domain.getStatus());
        entity.setBusinessHours(domain.getBusinessHours());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
