package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.RolePermissionRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.RolePermissionResponseDto;
import com.mamukas.erp.erpbackend.application.services.RolePermissionService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/role-permissions")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('USER')")
public class RolePermissionController {

    @Autowired
    private RolePermissionService rolePermissionService;

    /**
     * Assign permission to role
     */
    @PostMapping
    public ResponseEntity<RolePermissionResponseDto> assignPermissionToRole(@Valid @RequestBody RolePermissionRequestDto request) {
        try {
            RolePermissionResponseDto response = rolePermissionService.assignPermissionToRole(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get all role-permission assignments
     */
    @GetMapping
    public ResponseEntity<List<RolePermissionResponseDto>> getAllRolePermissions() {
        try {
            List<RolePermissionResponseDto> assignments = rolePermissionService.getAllRolePermissions();
            return new ResponseEntity<>(assignments, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get role-permission assignment by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<RolePermissionResponseDto> getRolePermissionById(@PathVariable Long id) {
        try {
            RolePermissionResponseDto assignment = rolePermissionService.getRolePermissionById(id);
            return new ResponseEntity<>(assignment, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get all permissions for a specific role
     */
    @GetMapping("/role/{idRole}")
    public ResponseEntity<List<RolePermissionResponseDto>> getPermissionsByRole(@PathVariable Long idRole) {
        try {
            List<RolePermissionResponseDto> permissions = rolePermissionService.getPermissionsByRole(idRole);
            return new ResponseEntity<>(permissions, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get all roles for a specific permission
     */
    @GetMapping("/permission/{idPermission}")
    public ResponseEntity<List<RolePermissionResponseDto>> getRolesByPermission(@PathVariable Long idPermission) {
        try {
            List<RolePermissionResponseDto> roles = rolePermissionService.getRolesByPermission(idPermission);
            return new ResponseEntity<>(roles, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Remove specific permission from role
     */
    @DeleteMapping("/role/{idRole}/permission/{idPermission}")
    public ResponseEntity<String> removePermissionFromRole(@PathVariable Long idRole, 
                                                          @PathVariable Long idPermission) {
        try {
            boolean removed = rolePermissionService.removePermissionFromRole(idRole, idPermission);
            if (removed) {
                return new ResponseEntity<>("Permiso removido del rol exitosamente", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Error al remover el permiso del rol", HttpStatus.INTERNAL_SERVER_ERROR);
            }
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>("Error interno del servidor", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Remove assignment by ID
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<String> removeRolePermission(@PathVariable Long id) {
        try {
            boolean removed = rolePermissionService.removeRolePermission(id);
            if (removed) {
                return new ResponseEntity<>("Asignación eliminada exitosamente", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Error al eliminar la asignación", HttpStatus.INTERNAL_SERVER_ERROR);
            }
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>("Error interno del servidor", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Remove all permissions from a role
     */
    @DeleteMapping("/role/{idRole}/permissions")
    public ResponseEntity<String> removeAllPermissionsFromRole(@PathVariable Long idRole) {
        try {
            boolean removed = rolePermissionService.removeAllPermissionsFromRole(idRole);
            if (removed) {
                return new ResponseEntity<>("Todos los permisos removidos del rol exitosamente", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Error al remover los permisos del rol", HttpStatus.INTERNAL_SERVER_ERROR);
            }
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>("Error interno del servidor", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Remove role from all permissions
     */
    @DeleteMapping("/permission/{idPermission}/roles")
    public ResponseEntity<String> removeRoleFromAllPermissions(@PathVariable Long idPermission) {
        try {
            boolean removed = rolePermissionService.removeRoleFromAllPermissions(idPermission);
            if (removed) {
                return new ResponseEntity<>("Rol removido de todos los permisos exitosamente", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Error al remover el rol de los permisos", HttpStatus.INTERNAL_SERVER_ERROR);
            }
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>("Error interno del servidor", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Check if permission is assigned to role
     */
    @GetMapping("/role/{idRole}/permission/{idPermission}/exists")
    public ResponseEntity<Boolean> isPermissionAssignedToRole(@PathVariable Long idRole, 
                                                             @PathVariable Long idPermission) {
        try {
            boolean assigned = rolePermissionService.isPermissionAssignedToRole(idRole, idPermission);
            return new ResponseEntity<>(assigned, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(false, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get total assignment count
     */
    @GetMapping("/count")
    public ResponseEntity<Long> getRolePermissionCount() {
        try {
            long count = rolePermissionService.getRolePermissionCount();
            return new ResponseEntity<>(count, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(0L, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
