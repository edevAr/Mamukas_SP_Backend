package com.mamukas.erp.erpbackend.infrastructure.persistence.repository;

import com.mamukas.erp.erpbackend.infrastructure.persistence.entity.AccountActivationTokenJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.List;

@Repository
public interface AccountActivationTokenJpaRepository extends JpaRepository<AccountActivationTokenJpaEntity, Long> {

    Optional<AccountActivationTokenJpaEntity> findByToken(String token);

    Optional<AccountActivationTokenJpaEntity> findByTokenAndUsed(String token, Boolean used);

    List<AccountActivationTokenJpaEntity> findByEmail(String email);

    List<AccountActivationTokenJpaEntity> findByEmailAndUsed(String email, Boolean used);

    @Query("SELECT a FROM AccountActivationTokenJpaEntity a WHERE a.expiresAt < :now")
    List<AccountActivationTokenJpaEntity> findExpiredTokens(@Param("now") LocalDateTime now);

    @Query("SELECT a FROM AccountActivationTokenJpaEntity a WHERE a.email = :email AND a.used = false AND a.expiresAt > :now")
    List<AccountActivationTokenJpaEntity> findValidTokensByEmail(@Param("email") String email, @Param("now") LocalDateTime now);

    void deleteByEmail(String email);

    void deleteByExpiresAtBefore(LocalDateTime dateTime);
}
