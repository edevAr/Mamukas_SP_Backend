package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Provider;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.ProviderJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProviderRepository extends JpaRepository<ProviderJpaEntity, Long> {
    
    // Custom query methods
    Optional<ProviderJpaEntity> findByIdProvider(Long idProvider);
    
    @Query("SELECT p FROM ProviderJpaEntity p WHERE p.nitOrCi = :nitOrCi")
    Optional<ProviderJpaEntity> findByNitOrCi(@Param("nitOrCi") String nitOrCi);
    
    Optional<ProviderJpaEntity> findByEmail(String email);
    
    List<ProviderJpaEntity> findByNameContaining(String name);
    
    List<ProviderJpaEntity> findByPhoneContaining(String phone);
    
    @Query("SELECT p FROM ProviderJpaEntity p WHERE p.name LIKE %:searchTerm% OR p.email LIKE %:searchTerm% OR p.nitOrCi LIKE %:searchTerm%")
    List<ProviderJpaEntity> searchProviders(@Param("searchTerm") String searchTerm);
    
    @Query("SELECT p FROM ProviderJpaEntity p WHERE p.email IS NOT NULL AND p.email != ''")
    List<ProviderJpaEntity> findProvidersWithEmail();
    
    @Query("SELECT p FROM ProviderJpaEntity p WHERE p.phone IS NOT NULL AND p.phone != ''")
    List<ProviderJpaEntity> findProvidersWithPhone();
    
    @Query("SELECT COUNT(p) FROM ProviderJpaEntity p")
    long countAllProviders();
    
    @Query("SELECT COUNT(p) > 0 FROM ProviderJpaEntity p WHERE p.nitOrCi = :nitOrCi")
    boolean existsByNitOrCi(@Param("nitOrCi") String nitOrCi);
    
    boolean existsByEmail(String email);
    
    // Conversion methods
    default Provider toDomain(ProviderJpaEntity entity) {
        return new Provider(
            entity.getIdProvider(),
            entity.getName(),
            entity.getPhone(),
            entity.getEmail(),
            entity.getNitOrCi(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    default ProviderJpaEntity toEntity(Provider domain) {
        ProviderJpaEntity entity = new ProviderJpaEntity();
        entity.setIdProvider(domain.getIdProvider());
        entity.setName(domain.getName());
        entity.setPhone(domain.getPhone());
        entity.setEmail(domain.getEmail());
        entity.setNitOrCi(domain.getNitOrCi());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
