package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.request.RolePermissionRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.RolePermissionResponseDto;
import com.mamukas.erp.erpbackend.domain.entities.RolePermission;
import com.mamukas.erp.erpbackend.domain.entities.Role;
import com.mamukas.erp.erpbackend.domain.entities.Permission;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.RolePermissionJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.RolePermissionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class RolePermissionService {
    
    private final RolePermissionRepository rolePermissionRepository;
    private final RoleService roleService;
    private final PermissionService permissionService;
    
    public RolePermissionService(RolePermissionRepository rolePermissionRepository,
                                RoleService roleService,
                                PermissionService permissionService) {
        this.rolePermissionRepository = rolePermissionRepository;
        this.roleService = roleService;
        this.permissionService = permissionService;
    }
    
    /**
     * Assign permission to role
     */
    public RolePermissionResponseDto assignPermissionToRole(RolePermissionRequestDto request) {
        // Validate that role and permission exist
        if (!roleService.existsById(request.getIdRole())) {
            throw new IllegalArgumentException("Rol con ID " + request.getIdRole() + " no encontrado");
        }
        
        if (!permissionService.existsById(request.getIdPermission())) {
            throw new IllegalArgumentException("Permiso con ID " + request.getIdPermission() + " no encontrado");
        }
        
        // Check if assignment already exists
        if (rolePermissionRepository.existsByIdRoleAndIdPermission(request.getIdRole(), request.getIdPermission())) {
            throw new IllegalArgumentException("El permiso ya está asignado a este rol");
        }
        
        // Create domain entity
        RolePermission rolePermission = new RolePermission(request.getIdRole(), request.getIdPermission());
        
        // Save assignment
        RolePermission savedRolePermission = save(rolePermission);
        
        return mapToResponseDto(savedRolePermission);
    }
    
    /**
     * Get all role-permission assignments
     */
    @Transactional(readOnly = true)
    public List<RolePermissionResponseDto> getAllRolePermissions() {
        return rolePermissionRepository.findAll()
                .stream()
                .map(rolePermissionRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Get role-permission assignment by ID
     */
    @Transactional(readOnly = true)
    public RolePermissionResponseDto getRolePermissionById(Long id) {
        RolePermission rolePermission = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Asignación con ID " + id + " no encontrada"));
        
        return mapToResponseDto(rolePermission);
    }
    
    /**
     * Get all permissions for a role
     */
    @Transactional(readOnly = true)
    public List<RolePermissionResponseDto> getPermissionsByRole(Long idRole) {
        if (!roleService.existsById(idRole)) {
            throw new IllegalArgumentException("Rol con ID " + idRole + " no encontrado");
        }
        
        return rolePermissionRepository.findByIdRole(idRole)
                .stream()
                .map(rolePermissionRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Get all roles for a permission
     */
    @Transactional(readOnly = true)
    public List<RolePermissionResponseDto> getRolesByPermission(Long idPermission) {
        if (!permissionService.existsById(idPermission)) {
            throw new IllegalArgumentException("Permiso con ID " + idPermission + " no encontrado");
        }
        
        return rolePermissionRepository.findByIdPermission(idPermission)
                .stream()
                .map(rolePermissionRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Remove permission from role
     */
    public boolean removePermissionFromRole(Long idRole, Long idPermission) {
        // Verify assignment exists
        if (!rolePermissionRepository.existsByIdRoleAndIdPermission(idRole, idPermission)) {
            throw new IllegalArgumentException("Asignación no encontrada");
        }
        
        rolePermissionRepository.deleteByIdRoleAndIdPermission(idRole, idPermission);
        return true;
    }
    
    /**
     * Remove assignment by ID
     */
    public boolean removeRolePermission(Long id) {
        if (!rolePermissionRepository.existsById(id)) {
            throw new IllegalArgumentException("Asignación con ID " + id + " no encontrada");
        }
        
        rolePermissionRepository.deleteById(id);
        return true;
    }
    
    /**
     * Remove all permissions from role
     */
    public boolean removeAllPermissionsFromRole(Long idRole) {
        if (!roleService.existsById(idRole)) {
            throw new IllegalArgumentException("Rol con ID " + idRole + " no encontrado");
        }
        
        rolePermissionRepository.deleteByIdRole(idRole);
        return true;
    }
    
    /**
     * Remove role from all permissions
     */
    public boolean removeRoleFromAllPermissions(Long idPermission) {
        if (!permissionService.existsById(idPermission)) {
            throw new IllegalArgumentException("Permiso con ID " + idPermission + " no encontrado");
        }
        
        rolePermissionRepository.deleteByIdPermission(idPermission);
        return true;
    }
    
    /**
     * Check if permission is assigned to role
     */
    @Transactional(readOnly = true)
    public boolean isPermissionAssignedToRole(Long idRole, Long idPermission) {
        return rolePermissionRepository.existsByIdRoleAndIdPermission(idRole, idPermission);
    }
    
    /**
     * Get assignment count
     */
    @Transactional(readOnly = true)
    public long getRolePermissionCount() {
        return rolePermissionRepository.count();
    }
    
    // Internal methods for domain operations
    
    /**
     * Find role-permission by ID (optional)
     */
    @Transactional(readOnly = true)
    public java.util.Optional<RolePermission> findById(Long id) {
        return rolePermissionRepository.findById(id).map(rolePermissionRepository::toDomain);
    }
    
    /**
     * Save role-permission (for direct domain operations)
     */
    public RolePermission save(RolePermission rolePermission) {
        RolePermissionJpaEntity jpaEntity = rolePermissionRepository.toJpaEntity(rolePermission);
        RolePermissionJpaEntity saved = rolePermissionRepository.save(jpaEntity);
        return rolePermissionRepository.toDomain(saved);
    }
    
    // Private helper methods
    
    private RolePermissionResponseDto mapToResponseDto(RolePermission rolePermission) {
        // Get role and permission names for enriched response
        String roleName = null;
        String permissionName = null;
        
        try {
            Role role = roleService.findById(rolePermission.getIdRole()).orElse(null);
            if (role != null) {
                roleName = role.getRoleName();
            }
            
            Permission permission = permissionService.findById(rolePermission.getIdPermission()).orElse(null);
            if (permission != null) {
                permissionName = permission.getName();
            }
        } catch (Exception e) {
            // In case of any issue getting names, continue without them
        }
        
        return new RolePermissionResponseDto(
            rolePermission.getIdRolePermission(),
            rolePermission.getIdRole(),
            rolePermission.getIdPermission(),
            roleName,
            permissionName,
            rolePermission.getCreatedAt(),
            rolePermission.getUpdatedAt()
        );
    }
}
