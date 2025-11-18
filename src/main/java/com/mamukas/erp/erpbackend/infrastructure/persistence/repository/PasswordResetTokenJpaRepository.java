package com.mamukas.erp.erpbackend.infrastructure.persistence.repository;

import com.mamukas.erp.erpbackend.infrastructure.persistence.entity.PasswordResetTokenJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.List;

@Repository
public interface PasswordResetTokenJpaRepository extends JpaRepository<PasswordResetTokenJpaEntity, Long> {

    Optional<PasswordResetTokenJpaEntity> findByToken(String token);

    Optional<PasswordResetTokenJpaEntity> findByTokenAndUsed(String token, Boolean used);

    List<PasswordResetTokenJpaEntity> findByEmail(String email);

    List<PasswordResetTokenJpaEntity> findByEmailAndUsed(String email, Boolean used);

    @Query("SELECT p FROM PasswordResetTokenJpaEntity p WHERE p.expiresAt < :now")
    List<PasswordResetTokenJpaEntity> findExpiredTokens(@Param("now") LocalDateTime now);

    @Query("SELECT p FROM PasswordResetTokenJpaEntity p WHERE p.email = :email AND p.used = false AND p.expiresAt > :now")
    List<PasswordResetTokenJpaEntity> findValidTokensByEmail(@Param("email") String email, @Param("now") LocalDateTime now);

    void deleteByEmail(String email);

    void deleteByExpiresAtBefore(LocalDateTime dateTime);
}
