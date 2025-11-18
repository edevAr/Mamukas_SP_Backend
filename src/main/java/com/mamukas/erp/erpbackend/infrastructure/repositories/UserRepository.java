package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.User;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.UserJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Unified User repository that handles both domain entities and JPA persistence
 * This repository combines Spring Data JPA functionality with domain-specific methods
 * It automatically handles mapping between User (domain) and UserJpaEntity (persistence)
 */
@Repository
public interface UserRepository extends JpaRepository<UserJpaEntity, Long> {
    
    // ==================== BASIC FINDERS ====================
    
    /**
     * Find user by username
     */
    Optional<UserJpaEntity> findByUsername(String username);
    
    /**
     * Find user by email
     */
    Optional<UserJpaEntity> findByEmail(String email);
    
    /**
     * Find user by CI
     */
    Optional<UserJpaEntity> findByCi(String ci);
    
    /**
     * Find users by status (0: Pending, 1: Active, 2: Inactive)
     */
    List<UserJpaEntity> findByStatus(Integer status);
    
    // ==================== EXISTENCE CHECKS ====================
    
    /**
     * Check if username exists
     */
    boolean existsByUsername(String username);
    
    /**
     * Check if email exists
     */
    boolean existsByEmail(String email);
    
    /**
     * Check if CI exists
     */
    boolean existsByCi(String ci);
    
    // ==================== COUNT METHODS ====================
    
    /**
     * Count users by status (0: Pending, 1: Active, 2: Inactive)
     */
    long countByStatus(Integer status);
    
    // ==================== CUSTOM QUERIES ====================
    
    /**
     * Find active users ordered by name
     */
    @Query("SELECT u FROM UserJpaEntity u WHERE u.status = 1 ORDER BY u.name, u.lastName")
    List<UserJpaEntity> findActiveUsersOrderByName();
    
    /**
     * Find users by name containing (case insensitive search)
     */
    @Query("SELECT u FROM UserJpaEntity u WHERE LOWER(u.name) LIKE LOWER(CONCAT('%', :name, '%')) OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<UserJpaEntity> findByNameContainingIgnoreCase(@Param("name") String name);
    
    /**
     * Find users created in the last N days
     */
    @Query(value = "SELECT * FROM users u WHERE u.created_at >= DATE_SUB(CURDATE(), INTERVAL :days DAY)", nativeQuery = true)
    List<UserJpaEntity> findUsersCreatedInLastDays(@Param("days") int days);
    
    /**
     * Count active users
     */
    @Query("SELECT COUNT(u) FROM UserJpaEntity u WHERE u.status = 1")
    long countActiveUsers();
    
    /**
     * Count inactive users
     */
    @Query("SELECT COUNT(u) FROM UserJpaEntity u WHERE u.status = 2")
    long countInactiveUsers();
    
    /**
     * Count pending users
     */
    @Query("SELECT COUNT(u) FROM UserJpaEntity u WHERE u.status = 0")
    long countPendingUsers();
    
    // ==================== DOMAIN HELPER METHODS ====================
    
    /**
     * Convert JPA entity to domain entity
     */
    default User toDomain(UserJpaEntity jpaEntity) {
        if (jpaEntity == null) return null;
        
        User user = new User();
        user.setIdUser(jpaEntity.getIdUser());
        user.setUsername(jpaEntity.getUsername());
        user.setEmail(jpaEntity.getEmail());
        user.setPassword(jpaEntity.getPassword());
        user.setName(jpaEntity.getName());
        user.setLastName(jpaEntity.getLastName());
        user.setAge(jpaEntity.getAge());
        user.setCi(jpaEntity.getCi());
        user.setStatus(jpaEntity.getStatus());
        user.setEmailVerified(jpaEntity.getEmailVerified());
        user.setRoleId(jpaEntity.getRoleId());
        return user;
    }
    
    /**
     * Convert domain entity to JPA entity
     */
    default UserJpaEntity toJpaEntity(User user) {
        if (user == null) return null;
        
        UserJpaEntity jpaEntity = new UserJpaEntity();
        jpaEntity.setIdUser(user.getIdUser());
        jpaEntity.setUsername(user.getUsername());
        jpaEntity.setEmail(user.getEmail());
        jpaEntity.setPassword(user.getPassword());
        jpaEntity.setName(user.getName());
        jpaEntity.setLastName(user.getLastName());
        jpaEntity.setAge(user.getAge());
        jpaEntity.setCi(user.getCi());
        jpaEntity.setStatus(user.getStatus());
        jpaEntity.setEmailVerified(user.getEmailVerified());
        jpaEntity.setRoleId(user.getRoleId());
        return jpaEntity;
    }
}
