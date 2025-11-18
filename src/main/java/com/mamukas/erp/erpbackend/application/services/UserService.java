package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.user.UserRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.user.UserResponseDto;
import com.mamukas.erp.erpbackend.domain.entities.Role;
import com.mamukas.erp.erpbackend.domain.entities.User;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.UserJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * User service containing all business logic for user operations
 * This service encapsulates all use cases in a single class for simplicity
 */
@Service
@Transactional
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final RoleService roleService;
    private final RolePermissionService rolePermissionService;
    
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder, 
                      RoleService roleService, RolePermissionService rolePermissionService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.roleService = roleService;
        this.rolePermissionService = rolePermissionService;
    }
    
    /**
     * Create a new user
     * @param userRequestDto the user data
     * @return UserResponseDto with the created user
     * @throws IllegalArgumentException if validation fails
     */
    public UserResponseDto createUser(UserRequestDto userRequestDto) {
        // Validate unique constraints
        validateUniqueConstraints(userRequestDto, null);
        
        // Resolve role name to role ID
        Long roleId = null;
        if (userRequestDto.getRoleName() != null) {
            Role role = roleService.findByRoleName(userRequestDto.getRoleName())
                .orElseThrow(() -> new IllegalArgumentException("Role '" + userRequestDto.getRoleName() + "' not found"));
            roleId = role.getIdRole();
        }
        
        // Create domain entity
        User user = new User(
            userRequestDto.getUsername(),
            userRequestDto.getEmail(),
            passwordEncoder.encode(userRequestDto.getPassword()),
            userRequestDto.getName(),
            userRequestDto.getLastName(),
            userRequestDto.getAge(),
            userRequestDto.getCi(),
            userRequestDto.getStatus() != null ? userRequestDto.getStatus() : 1, // 1 = Activo por defecto
            roleId
        );
        
        // Save user
        User savedUser = save(user);
        
        return mapToResponseDto(savedUser);
    }
    
    /**
     * Get all users
     * @return List of UserResponseDto
     */
    @Transactional(readOnly = true)
    public List<UserResponseDto> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(userRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Get users by status
     * @param status the status to filter by (0: Pending, 1: Active, 2: Inactive)
     * @return List of UserResponseDto
     */
    @Transactional(readOnly = true)
    public List<UserResponseDto> getUsersByStatus(Integer status) {
        return userRepository.findByStatus(status)
                .stream()
                .map(userRepository::toDomain)
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Get user by ID
     * @param id the user ID
     * @return UserResponseDto
     * @throws IllegalArgumentException if user not found
     */
    @Transactional(readOnly = true)
    public UserResponseDto getUserById(Long id) {
        User user = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User with ID " + id + " not found"));
        
        return mapToResponseDto(user);
    }
    
    /**
     * Get user by username
     * @param username the username
     * @return UserResponseDto
     * @throws IllegalArgumentException if user not found
     */
    @Transactional(readOnly = true)
    public UserResponseDto getUserByUsername(String username) {
        User user = findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("User with username '" + username + "' not found"));
        
        return mapToResponseDto(user);
    }
    
    /**
     * Get user by email
     * @param email the email
     * @return UserResponseDto
     * @throws IllegalArgumentException if user not found
     */
    @Transactional(readOnly = true)
    public UserResponseDto getUserByEmail(String email) {
        User user = findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User with email '" + email + "' not found"));
        
        return mapToResponseDto(user);
    }
    
    /**
     * Update user
     * @param id the user ID
     * @param userRequestDto the updated user data
     * @return UserResponseDto with updated user
     * @throws IllegalArgumentException if user not found or validation fails
     */
    public UserResponseDto updateUser(Long id, UserRequestDto userRequestDto) {
        // Find existing user
        User existingUser = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User with ID " + id + " not found"));
        
        // Validate unique constraints (excluding current user)
        validateUniqueConstraints(userRequestDto, id);
        
        // Update fields
        updateUserFields(existingUser, userRequestDto);
        
        // Save updated user
        User updatedUser = save(existingUser);
        
        return mapToResponseDto(updatedUser);
    }
    
    /**
     * Delete user (hard delete)
     * @param id the user ID
     * @return true if deletion was successful
     * @throws IllegalArgumentException if user not found
     */
    public boolean deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new IllegalArgumentException("User with ID " + id + " not found");
        }
        
        userRepository.deleteById(id);
        return true;
    }
    
    /**
     * Deactivate user (soft delete)
     * @param id the user ID
     * @return UserResponseDto with deactivated user
     * @throws IllegalArgumentException if user not found
     */
    public UserResponseDto deactivateUser(Long id) {
        User user = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User with ID " + id + " not found"));
        
        user.deactivate();
        User updatedUser = save(user);
        
        return mapToResponseDto(updatedUser);
    }
    
    /**
     * Activate user
     * @param id the user ID
     * @return UserResponseDto with activated user
     * @throws IllegalArgumentException if user not found
     */
    public UserResponseDto activateUser(Long id) {
        User user = findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User with ID " + id + " not found"));
        
        user.activate();
        User updatedUser = save(user);
        
        return mapToResponseDto(updatedUser);
    }
    
    /**
     * Check if user exists by ID
     * @param id the user ID
     * @return true if user exists
     */
    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return userRepository.existsById(id);
    }
    
    /**
     * Get user count
     * @return total number of users
     */
    @Transactional(readOnly = true)
    public long getUserCount() {
        return userRepository.count();
    }
    
    /**
     * Get active user count
     * @return number of active users (status = 1)
     */
    @Transactional(readOnly = true)
    public long getActiveUserCount() {
        return userRepository.countByStatus(1); // 1 = Active
    }

    /**
     * Get pending user count
     * @return number of pending users (status = 0)
     */
    @Transactional(readOnly = true)
    public long getPendingUserCount() {
        return userRepository.countByStatus(0); // 0 = Pending
    }

    /**
     * Get inactive user count
     * @return number of inactive users (status = 2)
     */
    @Transactional(readOnly = true)
    public long getInactiveUserCount() {
        return userRepository.countByStatus(2); // 2 = Inactive
    }

    // Additional methods for AuthService

    /**
     * Check if user exists by email
     * @param email the email
     * @return true if user exists
     */
    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    /**
     * Check if user exists by username
     * @param username the username
     * @return true if user exists
     */
    @Transactional(readOnly = true)
    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    /**
     * Find user by email (optional)
     * @param email the email
     * @return Optional<User>
     */
    @Transactional(readOnly = true)
    public java.util.Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email).map(userRepository::toDomain);
    }

    /**
     * Find user by username (optional)
     * @param username the username
     * @return Optional<User>
     */
    @Transactional(readOnly = true)
    public java.util.Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username).map(userRepository::toDomain);
    }

    /**
     * Find user by ID (optional)
     * @param id the user ID
     * @return Optional<User>
     */
    @Transactional(readOnly = true)
    public java.util.Optional<User> findById(Long id) {
        return userRepository.findById(id).map(userRepository::toDomain);
    }

    /**
     * Save user (for direct domain operations)
     * @param user the user domain entity
     * @return User saved user
     */
    public User save(User user) {
        UserJpaEntity jpaEntity = userRepository.toJpaEntity(user);
        UserJpaEntity saved = userRepository.save(jpaEntity);
        return userRepository.toDomain(saved);
    }
    
    /**
     * Get user permissions based on role
     * @param user the user
     * @return List of permission names
     */
    @Transactional(readOnly = true)
    public List<String> getUserPermissions(User user) {
        if (user.getRoleId() == null) {
            return List.of();
        }
        
        try {
            Role role = roleService.findById(user.getRoleId()).orElse(null);
            if (role == null) {
                return List.of();
            }
            
            // Get role permissions using RolePermissionService
            return rolePermissionService.getPermissionsByRole(user.getRoleId())
                    .stream()
                    .map(rp -> rp.getPermissionName())
                    .filter(name -> name != null)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            // Log error and return empty list
            return List.of();
        }
    }
    
    /**
     * Get user role name
     * @param user the user
     * @return role name or null
     */
    @Transactional(readOnly = true)
    public String getUserRoleName(User user) {
        if (user.getRoleId() == null) {
            return null;
        }
        
        try {
            Role role = roleService.findById(user.getRoleId()).orElse(null);
            return role != null ? role.getRoleName() : null;
        } catch (Exception e) {
            return null;
        }
    }
    
    // Private helper methods
    
    private void validateUniqueConstraints(UserRequestDto dto, Long excludeUserId) {
        // Check username uniqueness
        if (dto.getUsername() != null && userRepository.existsByUsername(dto.getUsername())) {
            // If updating, check if it's the same user
            if (excludeUserId == null || !userRepository.findByUsername(dto.getUsername())
                    .map(jpa -> userRepository.toDomain(jpa).getIdUser()).equals(excludeUserId)) {
                throw new IllegalArgumentException("Username '" + dto.getUsername() + "' already exists");
            }
        }
        
        // Check email uniqueness
        if (dto.getEmail() != null && userRepository.existsByEmail(dto.getEmail())) {
            if (excludeUserId == null || !userRepository.findByEmail(dto.getEmail())
                    .map(jpa -> userRepository.toDomain(jpa).getIdUser()).equals(excludeUserId)) {
                throw new IllegalArgumentException("Email '" + dto.getEmail() + "' already exists");
            }
        }
        
        // Check CI uniqueness
        if (dto.getCi() != null && userRepository.existsByCi(dto.getCi())) {
            if (excludeUserId == null || !userRepository.findByCi(dto.getCi())
                    .map(jpa -> userRepository.toDomain(jpa).getIdUser()).equals(excludeUserId)) {
                throw new IllegalArgumentException("CI '" + dto.getCi() + "' already exists");
            }
        }
    }
    
    private void updateUserFields(User user, UserRequestDto dto) {
        if (dto.getUsername() != null) {
            user.setUsername(dto.getUsername());
        }
        if (dto.getEmail() != null) {
            user.setEmail(dto.getEmail());
        }
        if (dto.getPassword() != null && !dto.getPassword().trim().isEmpty()) {
            user.setPassword(passwordEncoder.encode(dto.getPassword()));
        }
        if (dto.getName() != null) {
            user.setName(dto.getName());
        }
        if (dto.getLastName() != null) {
            user.setLastName(dto.getLastName());
        }
        if (dto.getAge() != null) {
            user.setAge(dto.getAge());
        }
        if (dto.getCi() != null) {
            user.setCi(dto.getCi());
        }
        if (dto.getStatus() != null) {
            user.setStatus(dto.getStatus());
        }
        if (dto.getRoleName() != null) {
            Role role = roleService.findByRoleName(dto.getRoleName())
                .orElseThrow(() -> new IllegalArgumentException("Role '" + dto.getRoleName() + "' not found"));
            user.setRoleId(role.getIdRole());
        }
    }
    
    private UserResponseDto mapToResponseDto(User user) {
        String roleName = null;
        if (user.getRoleId() != null) {
            try {
                Role role = roleService.findById(user.getRoleId())
                    .orElse(null);
                if (role != null) {
                    roleName = role.getRoleName();
                }
            } catch (Exception e) {
                // Log error but continue without role name
                roleName = "Unknown";
            }
        }
        
        return new UserResponseDto(
            user.getIdUser(),
            user.getUsername(),
            user.getEmail(),
            user.getName(),
            user.getLastName(),
            user.getAge(),
            user.getCi(),
            user.getStatus(),
            roleName
        );
    }
}
