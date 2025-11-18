package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.request.EmployeeStoreRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.EmployeeStoreResponseDto;
import com.mamukas.erp.erpbackend.domain.entities.EmployeeStore;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.EmployeeStoreJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.EmployeeStoreRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class EmployeeStoreService {

    private final EmployeeStoreRepository employeeStoreRepository;
    private final StoreService storeService;

    public EmployeeStoreService(EmployeeStoreRepository employeeStoreRepository,
                               StoreService storeService) {
        this.employeeStoreRepository = employeeStoreRepository;
        this.storeService = storeService;
    }

    /**
     * Assign employee to store
     */
    public EmployeeStoreResponseDto assignEmployeeToStore(EmployeeStoreRequestDto request) {
        // Validate that store exists
        if (!storeService.existsById(request.getIdStore())) {
            throw new IllegalArgumentException("Tienda con ID " + request.getIdStore() + " no encontrada");
        }
        
        // Check if assignment already exists
        if (employeeStoreRepository.existsByIdEmployeeAndIdStore(request.getIdEmployee(), request.getIdStore())) {
            throw new IllegalArgumentException("El empleado ya está asignado a esta tienda");
        }
        
        // Create domain entity
        EmployeeStore employeeStore = new EmployeeStore(request.getIdEmployee(), request.getIdStore());
        
        // Save assignment
        EmployeeStore savedEmployeeStore = save(employeeStore);
        
        return mapToResponseDto(savedEmployeeStore);
    }

    /**
     * Get all employee-store assignments
     */
    @Transactional(readOnly = true)
    public List<EmployeeStoreResponseDto> getAllEmployeeStores() {
        return employeeStoreRepository.findAll()
                .stream()
                .map(employeeStoreRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get employee-store assignment by ID
     */
    @Transactional(readOnly = true)
    public EmployeeStoreResponseDto getEmployeeStoreById(Long id) {
        return employeeStoreRepository.findById(id)
                .map(employeeStoreRepository::toDomain)
                .map(this::mapToResponseDto)
                .orElseThrow(() -> new IllegalArgumentException("Asignación con ID " + id + " no encontrada"));
    }

    /**
     * Get all stores for an employee
     */
    @Transactional(readOnly = true)
    public List<EmployeeStoreResponseDto> getStoresByEmployee(Long idEmployee) {
        return employeeStoreRepository.findByIdEmployee(idEmployee)
                .stream()
                .map(employeeStoreRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Get all employees for a store
     */
    @Transactional(readOnly = true)
    public List<EmployeeStoreResponseDto> getEmployeesByStore(Long idStore) {
        if (!storeService.existsById(idStore)) {
            throw new IllegalArgumentException("Tienda con ID " + idStore + " no encontrada");
        }
        
        return employeeStoreRepository.findByIdStore(idStore)
                .stream()
                .map(employeeStoreRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Remove employee from store
     */
    public boolean removeEmployeeFromStore(Long idEmployee, Long idStore) {
        // Verify assignment exists
        if (!employeeStoreRepository.existsByIdEmployeeAndIdStore(idEmployee, idStore)) {
            throw new IllegalArgumentException("Asignación no encontrada");
        }
        
        employeeStoreRepository.deleteByIdEmployeeAndIdStore(idEmployee, idStore);
        return true;
    }

    /**
     * Remove assignment by ID
     */
    public boolean removeEmployeeStore(Long id) {
        if (!employeeStoreRepository.existsById(id)) {
            throw new IllegalArgumentException("Asignación con ID " + id + " no encontrada");
        }
        
        employeeStoreRepository.deleteById(id);
        return true;
    }

    /**
     * Remove all stores from employee
     */
    public boolean removeAllStoresFromEmployee(Long idEmployee) {
        employeeStoreRepository.deleteByIdEmployee(idEmployee);
        return true;
    }

    /**
     * Remove all employees from store
     */
    public boolean removeAllEmployeesFromStore(Long idStore) {
        if (!storeService.existsById(idStore)) {
            throw new IllegalArgumentException("Tienda con ID " + idStore + " no encontrada");
        }
        
        employeeStoreRepository.deleteByIdStore(idStore);
        return true;
    }

    /**
     * Check if employee is assigned to store
     */
    @Transactional(readOnly = true)
    public boolean isEmployeeAssignedToStore(Long idEmployee, Long idStore) {
        return employeeStoreRepository.existsByIdEmployeeAndIdStore(idEmployee, idStore);
    }

    /**
     * Get assignment count
     */
    @Transactional(readOnly = true)
    public long getEmployeeStoreCount() {
        return employeeStoreRepository.count();
    }

    /**
     * Check if assignment exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return employeeStoreRepository.existsById(id);
    }

    /**
     * Find employee-store by ID (optional)
     */
    @Transactional(readOnly = true)
    public java.util.Optional<EmployeeStore> findById(Long id) {
        return employeeStoreRepository.findById(id).map(employeeStoreRepository::toDomain);
    }

    /**
     * Save employee-store (for direct domain operations)
     */
    public EmployeeStore save(EmployeeStore employeeStore) {
        EmployeeStoreJpaEntity jpaEntity = employeeStoreRepository.toJpaEntity(employeeStore);
        EmployeeStoreJpaEntity saved = employeeStoreRepository.save(jpaEntity);
        return employeeStoreRepository.toDomain(saved);
    }

    /**
     * Map to response DTO
     */
    private EmployeeStoreResponseDto mapToResponseDto(EmployeeStore employeeStore) {
        return new EmployeeStoreResponseDto(
                employeeStore.getIdEmployeeStore(),
                employeeStore.getIdEmployee(),
                employeeStore.getIdStore(),
                employeeStore.getCreatedAt(),
                employeeStore.getUpdatedAt()
        );
    }
}
