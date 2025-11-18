package com.mamukas.erp.erpbackend.infrastructure.repositories;

import com.mamukas.erp.erpbackend.domain.entities.Session;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.SessionJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface SessionRepository extends JpaRepository<SessionJpaEntity, Long> {
    
    // Find active sessions by user
    List<SessionJpaEntity> findByIdUserAndStatus(Long idUser, String status);
    
    // Find all sessions by user
    List<SessionJpaEntity> findByIdUser(Long idUser);
    
    // Find sessions by status
    List<SessionJpaEntity> findByStatus(String status);
    
    // Find sessions by date range
    @Query("SELECT s FROM SessionJpaEntity s WHERE s.dateLogin BETWEEN :startDate AND :endDate")
    List<SessionJpaEntity> findByDateLoginBetween(@Param("startDate") LocalDateTime startDate, 
                                                  @Param("endDate") LocalDateTime endDate);
    
    // Find active sessions by user and device
    Optional<SessionJpaEntity> findByIdUserAndDeviceAndStatus(Long idUser, String device, String status);
    
    // Count active sessions by user
    Long countByIdUserAndStatus(Long idUser, String status);
    
    // Find most recent session by user
    @Query("SELECT s FROM SessionJpaEntity s WHERE s.idUser = :idUser ORDER BY s.dateLogin DESC")
    List<SessionJpaEntity> findMostRecentSessionByUser(@Param("idUser") Long idUser);
    
    // Conversion methods between domain and JPA entities
    default Session toDomain(SessionJpaEntity jpaEntity) {
        if (jpaEntity == null) return null;
        
        return new Session(
            jpaEntity.getIdSession(),
            jpaEntity.getStatus(),
            jpaEntity.getDateLogin(),
            jpaEntity.getDateLogout(),
            jpaEntity.getDevice(),
            jpaEntity.getIp(),
            jpaEntity.getIdUser(),
            jpaEntity.getCreatedAt(),
            jpaEntity.getUpdatedAt()
        );
    }
    
    default SessionJpaEntity toJpaEntity(Session session) {
        if (session == null) return null;
        
        SessionJpaEntity jpaEntity = new SessionJpaEntity();
        jpaEntity.setIdSession(session.getIdSession());
        jpaEntity.setStatus(session.getStatus());
        jpaEntity.setDateLogin(session.getDateLogin());
        jpaEntity.setDateLogout(session.getDateLogout());
        jpaEntity.setDevice(session.getDevice());
        jpaEntity.setIp(session.getIp());
        jpaEntity.setIdUser(session.getIdUser());
        jpaEntity.setCreatedAt(session.getCreatedAt());
        jpaEntity.setUpdatedAt(session.getUpdatedAt());
        
        return jpaEntity;
    }
}
