package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.user.UserRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.user.UserResponseDto;
import com.mamukas.erp.erpbackend.application.services.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST Controller for User operations
 * This controller handles HTTP requests and delegates to the UserService
 */
@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {
    
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    /**
     * Create a new user
     * POST /api/users
     */
    @PostMapping
    @PreAuthorize("hasAuthority('USER_MANAGEMENT_CREATE')")
    public ResponseEntity<ApiResponse<UserResponseDto>> createUser(@Valid @RequestBody UserRequestDto userRequestDto) {
        try {
            // Validate required fields for creation
            userRequestDto.validateForCreation();
            
            UserResponseDto createdUser = userService.createUser(userRequestDto);
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                true,
                "User created successfully",
                createdUser
            );
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                e.getMessage(),
                null
            );
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        } catch (Exception e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                "Internal server error occurred",
                null
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Get all users
     * GET /api/users
     */
    @GetMapping
    @PreAuthorize("hasAuthority('USER_MANAGEMENT_READ')")
    public ResponseEntity<ApiResponse<List<UserResponseDto>>> getAllUsers(
            @RequestParam(required = false) Integer status) {
        try {
            List<UserResponseDto> users = status != null ? 
                userService.getUsersByStatus(status) : 
                userService.getAllUsers();
            
            ApiResponse<List<UserResponseDto>> response = new ApiResponse<>(
                true,
                "Users retrieved successfully",
                users
            );
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            ApiResponse<List<UserResponseDto>> response = new ApiResponse<>(
                false,
                "Error retrieving users",
                null
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Get user by ID
     * GET /api/users/{id}
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('USER_MANAGEMENT_READ')")
    public ResponseEntity<ApiResponse<UserResponseDto>> getUserById(@PathVariable Long id) {
        try {
            UserResponseDto user = userService.getUserById(id);
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                true,
                "User retrieved successfully",
                user
            );
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                e.getMessage(),
                null
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        } catch (Exception e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                "Error retrieving user",
                null
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Get user by username
     * GET /api/users/username/{username}
     */
    @GetMapping("/username/{username}")
    @PreAuthorize("hasAuthority('USER_MANAGEMENT_READ')")
    public ResponseEntity<ApiResponse<UserResponseDto>> getUserByUsername(@PathVariable String username) {
        try {
            UserResponseDto user = userService.getUserByUsername(username);
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                true,
                "User retrieved successfully",
                user
            );
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                e.getMessage(),
                null
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        } catch (Exception e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                "Error retrieving user",
                null
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Update user
     * PUT /api/users/{id}
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('USER_MANAGEMENT_UPDATE')")
    public ResponseEntity<ApiResponse<UserResponseDto>> updateUser(
            @PathVariable Long id, 
            @Valid @RequestBody UserRequestDto userRequestDto) {
        try {
            // Validate that at least one field is provided for update
            userRequestDto.validateForUpdate();
            
            UserResponseDto updatedUser = userService.updateUser(id, userRequestDto);
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                true,
                "User updated successfully",
                updatedUser
            );
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                e.getMessage(),
                null
            );
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        } catch (Exception e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                "Error updating user",
                null
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Delete user (hard delete)
     * DELETE /api/users/{id}
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('USER_MANAGEMENT_DELETE')")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable Long id) {
        try {
            boolean deleted = userService.deleteUser(id);
            if (deleted) {
                ApiResponse<Void> response = new ApiResponse<>(
                    true,
                    "User deleted successfully",
                    null
                );
                return ResponseEntity.ok(response);
            } else {
                ApiResponse<Void> response = new ApiResponse<>(
                    false,
                    "Failed to delete user",
                    null
                );
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }
        } catch (IllegalArgumentException e) {
            ApiResponse<Void> response = new ApiResponse<>(
                false,
                e.getMessage(),
                null
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        } catch (Exception e) {
            ApiResponse<Void> response = new ApiResponse<>(
                false,
                "Error deleting user",
                null
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Deactivate user (soft delete)
     * PATCH /api/users/{id}/deactivate
     */
    @PatchMapping("/{id}/deactivate")
    @PreAuthorize("hasAuthority('USER_MANAGEMENT_UPDATE')")
    public ResponseEntity<ApiResponse<UserResponseDto>> deactivateUser(@PathVariable Long id) {
        try {
            UserResponseDto deactivatedUser = userService.deactivateUser(id);
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                true,
                "User deactivated successfully",
                deactivatedUser
            );
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                e.getMessage(),
                null
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        } catch (Exception e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                "Error deactivating user",
                null
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Activate user
     * PATCH /api/users/{id}/activate
     */
    @PatchMapping("/{id}/activate")
    @PreAuthorize("hasAuthority('USER_MANAGEMENT_UPDATE')")
    public ResponseEntity<ApiResponse<UserResponseDto>> activateUser(@PathVariable Long id) {
        try {
            UserResponseDto activatedUser = userService.activateUser(id);
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                true,
                "User activated successfully",
                activatedUser
            );
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                e.getMessage(),
                null
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        } catch (Exception e) {
            ApiResponse<UserResponseDto> response = new ApiResponse<>(
                false,
                "Error activating user",
                null
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * API Response wrapper class
     */
    public static class ApiResponse<T> {
        private boolean success;
        private String message;
        private T data;
        
        public ApiResponse(boolean success, String message, T data) {
            this.success = success;
            this.message = message;
            this.data = data;
        }
        
        // Getters and setters
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        
        public T getData() { return data; }
        public void setData(T data) { this.data = data; }
    }
}
