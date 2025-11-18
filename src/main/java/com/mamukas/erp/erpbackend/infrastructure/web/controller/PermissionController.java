package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.PermissionRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.PermissionResponseDto;
import com.mamukas.erp.erpbackend.application.services.PermissionService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/permissions")
@CrossOrigin(origins = "*")
public class PermissionController {

    @Autowired
    private PermissionService permissionService;

    /**
     * Create a new permission
     */
    @PostMapping
    public ResponseEntity<PermissionResponseDto> createPermission(@Valid @RequestBody PermissionRequestDto request) {
        try {
            PermissionResponseDto response = permissionService.createPermission(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get all permissions
     */
    @GetMapping
    public ResponseEntity<List<PermissionResponseDto>> getAllPermissions() {
        try {
            List<PermissionResponseDto> permissions = permissionService.getAllPermissions();
            return new ResponseEntity<>(permissions, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get permissions by status
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<List<PermissionResponseDto>> getPermissionsByStatus(@PathVariable Boolean status) {
        try {
            List<PermissionResponseDto> permissions = permissionService.getPermissionsByStatus(status);
            return new ResponseEntity<>(permissions, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get active permissions
     */
    @GetMapping("/active")
    public ResponseEntity<List<PermissionResponseDto>> getActivePermissions() {
        try {
            List<PermissionResponseDto> permissions = permissionService.getPermissionsByStatus(true);
            return new ResponseEntity<>(permissions, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get permission by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<PermissionResponseDto> getPermissionById(@PathVariable Long id) {
        try {
            PermissionResponseDto permission = permissionService.getPermissionById(id);
            return new ResponseEntity<>(permission, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get permission by name
     */
    @GetMapping("/by-name/{name}")
    public ResponseEntity<PermissionResponseDto> getPermissionByName(@PathVariable String name) {
        try {
            PermissionResponseDto permission = permissionService.getPermissionByName(name);
            return new ResponseEntity<>(permission, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Update permission
     */
    @PutMapping("/{id}")
    public ResponseEntity<PermissionResponseDto> updatePermission(@PathVariable Long id, 
                                                                 @Valid @RequestBody PermissionRequestDto request) {
        try {
            PermissionResponseDto response = permissionService.updatePermission(id, request);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Delete permission
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deletePermission(@PathVariable Long id) {
        try {
            boolean deleted = permissionService.deletePermission(id);
            if (deleted) {
                return new ResponseEntity<>("Permiso eliminado exitosamente", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Error al eliminar el permiso", HttpStatus.INTERNAL_SERVER_ERROR);
            }
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>("Error interno del servidor", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Activate permission
     */
    @PutMapping("/{id}/activate")
    public ResponseEntity<PermissionResponseDto> activatePermission(@PathVariable Long id) {
        try {
            PermissionResponseDto response = permissionService.activatePermission(id);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Deactivate permission
     */
    @PutMapping("/{id}/deactivate")
    public ResponseEntity<PermissionResponseDto> deactivatePermission(@PathVariable Long id) {
        try {
            PermissionResponseDto response = permissionService.deactivatePermission(id);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Check if permission exists
     */
    @GetMapping("/{id}/exists")
    public ResponseEntity<Boolean> permissionExists(@PathVariable Long id) {
        try {
            boolean exists = permissionService.existsById(id);
            return new ResponseEntity<>(exists, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(false, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get permission count
     */
    @GetMapping("/count")
    public ResponseEntity<Long> getPermissionCount() {
        try {
            long count = permissionService.getPermissionCount();
            return new ResponseEntity<>(count, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(0L, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get active permission count
     */
    @GetMapping("/count/active")
    public ResponseEntity<Long> getActivePermissionCount() {
        try {
            long count = permissionService.getActivePermissionCount();
            return new ResponseEntity<>(count, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(0L, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
