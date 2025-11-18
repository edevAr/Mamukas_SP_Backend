package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.request.CompanyRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.CompanyResponseDto;
import com.mamukas.erp.erpbackend.domain.entities.Company;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.CompanyJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.CompanyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class CompanyService {

    @Autowired
    private CompanyRepository companyRepository;

    /**
     * Create a new company
     */
    public CompanyResponseDto createCompany(CompanyRequestDto request) {
        // Validate that company name doesn't exist
        if (companyRepository.existsByName(request.getName())) {
            throw new IllegalArgumentException("Ya existe una empresa con el nombre: " + request.getName());
        }

        // Create domain entity
        Company company = new Company(
                request.getName(),
                request.getAddress(),
                request.getStatus() != null ? request.getStatus() : "Opened",
                request.getBusinessHours()
        );

        // Save company
        Company savedCompany = save(company);

        return mapToResponseDto(savedCompany);
    }

    /**
     * Get all companies
     */
    @Transactional(readOnly = true)
    public List<CompanyResponseDto> getAllCompanies() {
        return companyRepository.findAll()
                .stream()
                .map(companyRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get company by ID
     */
    @Transactional(readOnly = true)
    public CompanyResponseDto getCompanyById(Long id) {
        return companyRepository.findByIdCompany(id)
                .map(companyRepository::toDomain)
                .map(this::mapToResponseDto)
                .orElseThrow(() -> new IllegalArgumentException("Empresa con ID " + id + " no encontrada"));
    }

    /**
     * Update a company
     */
    public CompanyResponseDto updateCompany(Long id, CompanyRequestDto request) {
        Company existingCompany = companyRepository.findByIdCompany(id)
                .map(companyRepository::toDomain)
                .orElseThrow(() -> new IllegalArgumentException("Empresa con ID " + id + " no encontrada"));

        // Validate unique name if name changed
        if (!request.getName().equals(existingCompany.getName()) && 
            companyRepository.existsByNameAndIdCompanyNot(request.getName(), id)) {
            throw new IllegalArgumentException("Ya existe una empresa con el nombre: " + request.getName());
        }

        // Update fields
        existingCompany.setName(request.getName());
        existingCompany.setAddress(request.getAddress());
        existingCompany.setStatus(request.getStatus() != null ? request.getStatus() : "Opened");
        existingCompany.setBusinessHours(request.getBusinessHours());

        Company savedCompany = save(existingCompany);

        return mapToResponseDto(savedCompany);
    }

    /**
     * Delete a company
     */
    public boolean deleteCompany(Long id) {
        if (!companyRepository.existsById(id)) {
            throw new IllegalArgumentException("Empresa con ID " + id + " no encontrada");
        }

        companyRepository.deleteById(id);
        return true;
    }

    /**
     * Open company
     */
    public CompanyResponseDto openCompany(Long id) {
        Company company = companyRepository.findByIdCompany(id)
                .map(companyRepository::toDomain)
                .orElseThrow(() -> new IllegalArgumentException("Empresa con ID " + id + " no encontrada"));

        company.open();
        Company savedCompany = save(company);

        return mapToResponseDto(savedCompany);
    }

    /**
     * Close company
     */
    public CompanyResponseDto closeCompany(Long id) {
        Company company = companyRepository.findByIdCompany(id)
                .map(companyRepository::toDomain)
                .orElseThrow(() -> new IllegalArgumentException("Empresa con ID " + id + " no encontrada"));

        company.close();
        Company savedCompany = save(company);

        return mapToResponseDto(savedCompany);
    }

    /**
     * Get companies by status
     */
    @Transactional(readOnly = true)
    public List<CompanyResponseDto> getCompaniesByStatus(String status) {
        return companyRepository.findByStatus(status)
                .stream()
                .map(companyRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get opened companies
     */
    @Transactional(readOnly = true)
    public List<CompanyResponseDto> getOpenedCompanies() {
        return getCompaniesByStatus("Opened");
    }

    /**
     * Get closed companies
     */
    @Transactional(readOnly = true)
    public List<CompanyResponseDto> getClosedCompanies() {
        return getCompaniesByStatus("Closed");
    }

    /**
     * Search companies by name
     */
    @Transactional(readOnly = true)
    public List<CompanyResponseDto> searchCompaniesByName(String name) {
        return companyRepository.findByNameContainingIgnoreCase(name)
                .stream()
                .map(companyRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Search companies by address
     */
    @Transactional(readOnly = true)
    public List<CompanyResponseDto> searchCompaniesByAddress(String address) {
        return companyRepository.findByAddressContainingIgnoreCase(address)
                .stream()
                .map(companyRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Search companies by name and status
     */
    @Transactional(readOnly = true)
    public List<CompanyResponseDto> searchCompaniesByNameAndStatus(String name, String status) {
        return companyRepository.findByNameAndStatus(name, status)
                .stream()
                .map(companyRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Search companies by address and status
     */
    @Transactional(readOnly = true)
    public List<CompanyResponseDto> searchCompaniesByAddressAndStatus(String address, String status) {
        return companyRepository.findByAddressAndStatus(address, status)
                .stream()
                .map(companyRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Check if company exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return companyRepository.existsById(id);
    }

    /**
     * Get company count
     */
    @Transactional(readOnly = true)
    public long getCompanyCount() {
        return companyRepository.count();
    }

    /**
     * Find company by ID (optional)
     */
    @Transactional(readOnly = true)
    public Optional<Company> findById(Long id) {
        return companyRepository.findByIdCompany(id).map(companyRepository::toDomain);
    }

    /**
     * Save company (for direct domain operations)
     */
    public Company save(Company company) {
        CompanyJpaEntity jpaEntity = companyRepository.toJpaEntity(company);
        CompanyJpaEntity saved = companyRepository.save(jpaEntity);
        return companyRepository.toDomain(saved);
    }

    /**
     * Map to response DTO
     */
    private CompanyResponseDto mapToResponseDto(Company company) {
        return new CompanyResponseDto(
                company.getIdCompany(),
                company.getName(),
                company.getAddress(),
                company.getStatus(),
                company.getBusinessHours(),
                company.getCreatedAt(),
                company.getUpdatedAt()
        );
    }
}
