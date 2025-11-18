package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.role.RoleRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.role.RoleResponseDto;
import com.mamukas.erp.erpbackend.application.services.RoleService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/roles")
@CrossOrigin(origins = "*")
public class RoleController {

    @Autowired
    private RoleService roleService;

    /**
     * Create a new role
     */
    @PostMapping
    public ResponseEntity<RoleResponseDto> createRole(@Valid @RequestBody RoleRequestDto request) {
        try {
            RoleResponseDto response = roleService.createRole(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get all roles
     */
    @GetMapping
    public ResponseEntity<List<RoleResponseDto>> getAllRoles() {
        try {
            List<RoleResponseDto> roles = roleService.getAllRoles();
            return new ResponseEntity<>(roles, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get role by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<RoleResponseDto> getRoleById(@PathVariable Long id) {
        try {
            RoleResponseDto role = roleService.getRoleById(id);
            return new ResponseEntity<>(role, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get role by name
     */
    @GetMapping("/by-name/{roleName}")
    public ResponseEntity<RoleResponseDto> getRoleByName(@PathVariable String roleName) {
        try {
            RoleResponseDto role = roleService.getRoleByName(roleName);
            return new ResponseEntity<>(role, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Update role
     */
    @PutMapping("/{id}")
    public ResponseEntity<RoleResponseDto> updateRole(@PathVariable Long id, 
                                                     @Valid @RequestBody RoleRequestDto request) {
        try {
            RoleResponseDto response = roleService.updateRole(id, request);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Delete role
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteRole(@PathVariable Long id) {
        try {
            boolean deleted = roleService.deleteRole(id);
            if (deleted) {
                return new ResponseEntity<>("Rol eliminado exitosamente", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Error al eliminar el rol", HttpStatus.INTERNAL_SERVER_ERROR);
            }
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>("Error interno del servidor", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Check if role exists
     */
    @GetMapping("/{id}/exists")
    public ResponseEntity<Boolean> roleExists(@PathVariable Long id) {
        try {
            boolean exists = roleService.existsById(id);
            return new ResponseEntity<>(exists, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(false, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Get role count
     */
    @GetMapping("/count")
    public ResponseEntity<Long> getRoleCount() {
        try {
            long count = roleService.getRoleCount();
            return new ResponseEntity<>(count, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(0L, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
