package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Customer;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.CustomerJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerRepository extends JpaRepository<CustomerJpaEntity, Long> {
    
    // Custom query methods
    Optional<CustomerJpaEntity> findByCustomerId(Long customerId);
    
    Optional<CustomerJpaEntity> findByNit(String nit);
    
    List<CustomerJpaEntity> findByNameContaining(String name);
    
    @Query("SELECT c FROM CustomerJpaEntity c WHERE c.name LIKE %:searchTerm% OR c.nit LIKE %:searchTerm%")
    List<CustomerJpaEntity> searchCustomers(@Param("searchTerm") String searchTerm);
    
    @Query("SELECT COUNT(c) FROM CustomerJpaEntity c")
    long countAllCustomers();
    
    boolean existsByNit(String nit);
    
    // Conversion methods
    default Customer toDomain(CustomerJpaEntity entity) {
        return new Customer(
            entity.getCustomerId(),
            entity.getName(),
            entity.getNit(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
    
    default CustomerJpaEntity toEntity(Customer domain) {
        CustomerJpaEntity entity = new CustomerJpaEntity();
        entity.setCustomerId(domain.getCustomerId());
        entity.setName(domain.getName());
        entity.setNit(domain.getNit());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
