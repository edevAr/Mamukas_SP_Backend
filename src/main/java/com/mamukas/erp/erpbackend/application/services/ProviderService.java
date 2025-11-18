package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.domain.entities.Provider;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.ProviderJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.ProviderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class ProviderService {
    
    @Autowired
    private ProviderRepository providerRepository;
    
    /**
     * Save provider
     */
    public Provider save(Provider provider) {
        ProviderJpaEntity entity = providerRepository.toEntity(provider);
        ProviderJpaEntity savedEntity = providerRepository.save(entity);
        return providerRepository.toDomain(savedEntity);
    }
    
    /**
     * Create new provider
     */
    public Provider createProvider(String name, String phone, String email, String nitOrCi) {
        if (providerRepository.existsByNitOrCi(nitOrCi)) {
            throw new RuntimeException("Provider with NIT/CI already exists: " + nitOrCi);
        }
        if (email != null && !email.trim().isEmpty() && providerRepository.existsByEmail(email)) {
            throw new RuntimeException("Provider with email already exists: " + email);
        }
        
        Provider provider = new Provider(name, phone, email, nitOrCi);
        if (!provider.isValidProvider()) {
            throw new RuntimeException("Invalid provider data");
        }
        
        return save(provider);
    }
    
    /**
     * Find provider by ID
     */
    @Transactional(readOnly = true)
    public Optional<Provider> findById(Long id) {
        Optional<ProviderJpaEntity> entity = providerRepository.findByIdProvider(id);
        return entity.map(providerRepository::toDomain);
    }
    
    /**
     * Find all providers
     */
    @Transactional(readOnly = true)
    public List<Provider> findAll() {
        return providerRepository.findAll()
                .stream()
                .map(providerRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find provider by NIT or CI
     */
    @Transactional(readOnly = true)
    public Optional<Provider> findByNitOrCi(String nitOrCi) {
        Optional<ProviderJpaEntity> entity = providerRepository.findByNitOrCi(nitOrCi);
        return entity.map(providerRepository::toDomain);
    }
    
    /**
     * Find provider by email
     */
    @Transactional(readOnly = true)
    public Optional<Provider> findByEmail(String email) {
        Optional<ProviderJpaEntity> entity = providerRepository.findByEmail(email);
        return entity.map(providerRepository::toDomain);
    }
    
    /**
     * Find providers by name containing text
     */
    @Transactional(readOnly = true)
    public List<Provider> findByNameContaining(String name) {
        return providerRepository.findByNameContaining(name)
                .stream()
                .map(providerRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find providers by phone containing text
     */
    @Transactional(readOnly = true)
    public List<Provider> findByPhoneContaining(String phone) {
        return providerRepository.findByPhoneContaining(phone)
                .stream()
                .map(providerRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Search providers by term (name, email, or nit/ci)
     */
    @Transactional(readOnly = true)
    public List<Provider> searchProviders(String searchTerm) {
        return providerRepository.searchProviders(searchTerm)
                .stream()
                .map(providerRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find providers with email
     */
    @Transactional(readOnly = true)
    public List<Provider> findProvidersWithEmail() {
        return providerRepository.findProvidersWithEmail()
                .stream()
                .map(providerRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Find providers with phone
     */
    @Transactional(readOnly = true)
    public List<Provider> findProvidersWithPhone() {
        return providerRepository.findProvidersWithPhone()
                .stream()
                .map(providerRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Update provider
     */
    public Provider updateProvider(Long id, String name, String phone, String email, String nitOrCi) {
        Optional<ProviderJpaEntity> entityOpt = providerRepository.findByIdProvider(id);
        if (entityOpt.isPresent()) {
            Provider existingProvider = providerRepository.toDomain(entityOpt.get());
            
            // Check if NIT/CI is being changed and if it already exists
            if (!existingProvider.getNitOrCi().equals(nitOrCi) && providerRepository.existsByNitOrCi(nitOrCi)) {
                throw new RuntimeException("Provider with NIT/CI already exists: " + nitOrCi);
            }
            
            // Check if email is being changed and if it already exists
            if (email != null && !email.trim().isEmpty() && 
                !email.equals(existingProvider.getEmail()) && providerRepository.existsByEmail(email)) {
                throw new RuntimeException("Provider with email already exists: " + email);
            }
            
            existingProvider.setName(name);
            existingProvider.setPhone(phone);
            existingProvider.setEmail(email);
            existingProvider.setNitOrCi(nitOrCi);
            
            if (!existingProvider.isValidProvider()) {
                throw new RuntimeException("Invalid provider data");
            }
            
            return save(existingProvider);
        }
        throw new RuntimeException("Provider not found with id: " + id);
    }
    
    /**
     * Count all providers
     */
    @Transactional(readOnly = true)
    public long countProviders() {
        return providerRepository.countAllProviders();
    }
    
    /**
     * Check if provider exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return providerRepository.existsById(id);
    }
    
    /**
     * Check if provider exists by NIT/CI
     */
    @Transactional(readOnly = true)
    public boolean existsByNitOrCi(String nitOrCi) {
        return providerRepository.existsByNitOrCi(nitOrCi);
    }
    
    /**
     * Check if provider exists by email
     */
    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return providerRepository.existsByEmail(email);
    }
    
    /**
     * Delete provider
     */
    public void deleteProvider(Long id) {
        if (providerRepository.existsById(id)) {
            providerRepository.deleteById(id);
        } else {
            throw new RuntimeException("Provider not found with id: " + id);
        }
    }
}
