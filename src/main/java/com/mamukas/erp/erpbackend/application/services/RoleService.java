package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.role.RoleRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.role.RoleResponseDto;
import com.mamukas.erp.erpbackend.domain.entities.Role;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.RoleJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.RoleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class RoleService {
    
    private final RoleRepository roleRepository;
    
    public RoleService(RoleRepository roleRepository) {
        this.roleRepository = roleRepository;
    }
    
    /**
     * Create a new role
     */
    public RoleResponseDto createRole(RoleRequestDto request) {
        // Validate unique role name
        if (roleRepository.existsByRoleName(request.getRoleName())) {
            throw new IllegalArgumentException("El rol '" + request.getRoleName() + "' ya existe");
        }
        
        // Create domain entity
        Role role = new Role(request.getRoleName());
        
        // Save role
        Role savedRole = save(role);
        
        return mapToResponseDto(savedRole);
    }
    
    /**
     * Get all roles
     */
    @Transactional(readOnly = true)
    public List<RoleResponseDto> getAllRoles() {
        return roleRepository.findAll()
                .stream()
                .map(roleRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Get role by ID
     */
    @Transactional(readOnly = true)
    public RoleResponseDto getRoleById(Long id) {
        Role role = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Rol con ID " + id + " no encontrado"));
        
        return mapToResponseDto(role);
    }
    
    /**
     * Get role by name
     */
    @Transactional(readOnly = true)
    public RoleResponseDto getRoleByName(String roleName) {
        Role role = findByRoleName(roleName)
                .orElseThrow(() -> new IllegalArgumentException("Rol '" + roleName + "' no encontrado"));
        
        return mapToResponseDto(role);
    }
    
    /**
     * Update role
     */
    public RoleResponseDto updateRole(Long id, RoleRequestDto request) {
        // Find existing role
        Role existingRole = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Rol con ID " + id + " no encontrado"));
        
        // Validate unique role name (excluding current role)
        if (roleRepository.existsByRoleName(request.getRoleName()) && 
            !existingRole.getRoleName().equals(request.getRoleName())) {
            throw new IllegalArgumentException("El rol '" + request.getRoleName() + "' ya existe");
        }
        
        // Update role name
        existingRole.updateRoleName(request.getRoleName());
        
        // Save updated role
        Role updatedRole = save(existingRole);
        
        return mapToResponseDto(updatedRole);
    }
    
    /**
     * Delete role
     */
    public boolean deleteRole(Long id) {
        if (!roleRepository.existsById(id)) {
            throw new IllegalArgumentException("Rol con ID " + id + " no encontrado");
        }
        
        roleRepository.deleteById(id);
        return true;
    }
    
    /**
     * Check if role exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return roleRepository.existsById(id);
    }
    
    /**
     * Check if role exists by name
     */
    @Transactional(readOnly = true)
    public boolean existsByRoleName(String roleName) {
        return roleRepository.existsByRoleName(roleName);
    }
    
    /**
     * Get role count
     */
    @Transactional(readOnly = true)
    public long getRoleCount() {
        return roleRepository.count();
    }
    
    // Internal methods for domain operations
    
    /**
     * Find role by ID (optional)
     */
    @Transactional(readOnly = true)
    public java.util.Optional<Role> findById(Long id) {
        return roleRepository.findById(id).map(roleRepository::toDomain);
    }
    
    /**
     * Find role by name (optional)
     */
    @Transactional(readOnly = true)
    public java.util.Optional<Role> findByRoleName(String roleName) {
        return roleRepository.findByRoleName(roleName).map(roleRepository::toDomain);
    }
    
    /**
     * Save role (for direct domain operations)
     */
    public Role save(Role role) {
        RoleJpaEntity jpaEntity = roleRepository.toJpaEntity(role);
        RoleJpaEntity saved = roleRepository.save(jpaEntity);
        return roleRepository.toDomain(saved);
    }
    
    // Private helper methods
    
    private RoleResponseDto mapToResponseDto(Role role) {
        return new RoleResponseDto(
            role.getIdRole(),
            role.getRoleName(),
            role.getCreatedAt(),
            role.getUpdatedAt()
        );
    }
}
