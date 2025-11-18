package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.request.PermissionRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.PermissionResponseDto;
import com.mamukas.erp.erpbackend.domain.entities.Permission;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.PermissionJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.PermissionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class PermissionService {
    
    private final PermissionRepository permissionRepository;
    
    public PermissionService(PermissionRepository permissionRepository) {
        this.permissionRepository = permissionRepository;
    }
    
    /**
     * Create a new permission
     */
    public PermissionResponseDto createPermission(PermissionRequestDto request) {
        // Validate unique permission name
        if (permissionRepository.existsByName(request.getName())) {
            throw new IllegalArgumentException("El permiso '" + request.getName() + "' ya existe");
        }
        
        // Create domain entity
        Permission permission = new Permission(request.getName(), request.getStatus());
        
        // Save permission
        Permission savedPermission = save(permission);
        
        return mapToResponseDto(savedPermission);
    }
    
    /**
     * Get all permissions
     */
    @Transactional(readOnly = true)
    public List<PermissionResponseDto> getAllPermissions() {
        return permissionRepository.findAll()
                .stream()
                .map(permissionRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Get permissions by status
     */
    @Transactional(readOnly = true)
    public List<PermissionResponseDto> getPermissionsByStatus(Boolean status) {
        return permissionRepository.findByStatus(status)
                .stream()
                .map(permissionRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Get permission by ID
     */
    @Transactional(readOnly = true)
    public PermissionResponseDto getPermissionById(Long id) {
        Permission permission = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Permiso con ID " + id + " no encontrado"));
        
        return mapToResponseDto(permission);
    }
    
    /**
     * Get permission by name
     */
    @Transactional(readOnly = true)
    public PermissionResponseDto getPermissionByName(String name) {
        Permission permission = findByName(name)
                .orElseThrow(() -> new IllegalArgumentException("Permiso '" + name + "' no encontrado"));
        
        return mapToResponseDto(permission);
    }
    
    /**
     * Update permission
     */
    public PermissionResponseDto updatePermission(Long id, PermissionRequestDto request) {
        // Find existing permission
        Permission existingPermission = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Permiso con ID " + id + " no encontrado"));
        
        // Validate unique permission name (excluding current permission)
        if (permissionRepository.existsByName(request.getName()) && 
            !existingPermission.getName().equals(request.getName())) {
            throw new IllegalArgumentException("El permiso '" + request.getName() + "' ya existe");
        }
        
        // Update permission fields
        existingPermission.updateName(request.getName());
        if (request.getStatus() != null) {
            existingPermission.setStatus(request.getStatus());
        }
        
        // Save updated permission
        Permission updatedPermission = save(existingPermission);
        
        return mapToResponseDto(updatedPermission);
    }
    
    /**
     * Delete permission
     */
    public boolean deletePermission(Long id) {
        if (!permissionRepository.existsById(id)) {
            throw new IllegalArgumentException("Permiso con ID " + id + " no encontrado");
        }
        
        permissionRepository.deleteById(id);
        return true;
    }
    
    /**
     * Activate permission
     */
    public PermissionResponseDto activatePermission(Long id) {
        Permission permission = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Permiso con ID " + id + " no encontrado"));
        
        permission.activate();
        Permission updatedPermission = save(permission);
        
        return mapToResponseDto(updatedPermission);
    }
    
    /**
     * Deactivate permission
     */
    public PermissionResponseDto deactivatePermission(Long id) {
        Permission permission = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Permiso con ID " + id + " no encontrado"));
        
        permission.deactivate();
        Permission updatedPermission = save(permission);
        
        return mapToResponseDto(updatedPermission);
    }
    
    /**
     * Check if permission exists by ID
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return permissionRepository.existsById(id);
    }
    
    /**
     * Check if permission exists by name
     */
    @Transactional(readOnly = true)
    public boolean existsByName(String name) {
        return permissionRepository.existsByName(name);
    }
    
    /**
     * Get permission count
     */
    @Transactional(readOnly = true)
    public long getPermissionCount() {
        return permissionRepository.count();
    }
    
    /**
     * Get active permission count
     */
    @Transactional(readOnly = true)
    public long getActivePermissionCount() {
        return permissionRepository.findByStatus(true).size();
    }
    
    // Internal methods for domain operations
    
    /**
     * Find permission by ID (optional)
     */
    @Transactional(readOnly = true)
    public java.util.Optional<Permission> findById(Long id) {
        return permissionRepository.findById(id).map(permissionRepository::toDomain);
    }
    
    /**
     * Find permission by name (optional)
     */
    @Transactional(readOnly = true)
    public java.util.Optional<Permission> findByName(String name) {
        return permissionRepository.findByName(name).map(permissionRepository::toDomain);
    }
    
    /**
     * Save permission (for direct domain operations)
     */
    public Permission save(Permission permission) {
        PermissionJpaEntity jpaEntity = permissionRepository.toJpaEntity(permission);
        PermissionJpaEntity saved = permissionRepository.save(jpaEntity);
        return permissionRepository.toDomain(saved);
    }
    
    // Private helper methods
    
    private PermissionResponseDto mapToResponseDto(Permission permission) {
        return new PermissionResponseDto(
            permission.getIdPermission(),
            permission.getName(),
            permission.getStatus(),
            permission.getCreatedAt(),
            permission.getUpdatedAt()
        );
    }
}
