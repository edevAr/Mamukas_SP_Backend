package com.mamukas.erp.erpbackend.infrastructure.persistence.repository;

import com.mamukas.erp.erpbackend.infrastructure.persistence.entity.RefreshTokenJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.List;

@Repository
public interface RefreshTokenJpaRepository extends JpaRepository<RefreshTokenJpaEntity, Long> {

    Optional<RefreshTokenJpaEntity> findByToken(String token);

    Optional<RefreshTokenJpaEntity> findByTokenAndRevoked(String token, Boolean revoked);

    List<RefreshTokenJpaEntity> findByIdUser(Long idUser);

    List<RefreshTokenJpaEntity> findByIdUserAndRevoked(Long idUser, Boolean revoked);

    @Query("SELECT r FROM RefreshTokenJpaEntity r WHERE r.expiresAt < :now")
    List<RefreshTokenJpaEntity> findExpiredTokens(@Param("now") LocalDateTime now);

    @Query("SELECT r FROM RefreshTokenJpaEntity r WHERE r.idUser = :idUser AND r.revoked = false AND r.expiresAt > :now")
    List<RefreshTokenJpaEntity> findValidTokensByIdUser(@Param("idUser") Long idUser, @Param("now") LocalDateTime now);

    void deleteByIdUser(Long idUser);

    void deleteByExpiresAtBefore(LocalDateTime dateTime);
}
