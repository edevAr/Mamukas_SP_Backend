package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.domain.entities.Session;
import com.mamukas.erp.erpbackend.infrastructure.persistence.jpa.SessionJpaEntity;
import com.mamukas.erp.erpbackend.infrastructure.repositories.SessionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class SessionService {
    
    private final SessionRepository sessionRepository;
    
    public SessionService(SessionRepository sessionRepository) {
        this.sessionRepository = sessionRepository;
    }
    
    /**
     * Create a new login session
     */
    public Session createLoginSession(Long idUser, String device, String ip) {
        // Create new active session (allow multiple concurrent sessions)
        Session session = new Session(
            "Active",
            LocalDateTime.now(),
            device,
            ip,
            idUser
        );
        
        return save(session);
    }
    
    /**
     * Update session with logout information
     */
    public Session logoutSession(Long idUser, String device) {
        Optional<SessionJpaEntity> sessionEntity = sessionRepository
            .findByIdUserAndDeviceAndStatus(idUser, device, "Active");
        
        if (sessionEntity.isPresent()) {
            Session session = sessionRepository.toDomain(sessionEntity.get());
            session.deactivate();
            return save(session);
        }
        
        return null;
    }
    
    /**
     * Deactivate all active sessions for a user
     */
    public void deactivateUserSessions(Long idUser) {
        List<SessionJpaEntity> activeSessions = sessionRepository
            .findByIdUserAndStatus(idUser, "Active");
        
        for (SessionJpaEntity sessionEntity : activeSessions) {
            Session session = sessionRepository.toDomain(sessionEntity);
            session.deactivate();
            save(session);
        }
    }
    
    /**
     * Deactivate specific session by session ID
     */
    public Session deactivateSpecificSession(Long sessionId) {
        Optional<SessionJpaEntity> sessionEntity = sessionRepository.findById(sessionId);
        
        if (sessionEntity.isPresent() && "Active".equals(sessionEntity.get().getStatus())) {
            Session session = sessionRepository.toDomain(sessionEntity.get());
            session.deactivate();
            return save(session);
        }
        
        return null;
    }
    
    /**
     * Get active sessions for user
     */
    @Transactional(readOnly = true)
    public List<Session> getActiveSessionsByUser(Long idUser) {
        return sessionRepository.findByIdUserAndStatus(idUser, "Active")
                .stream()
                .map(sessionRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Get all sessions for user
     */
    @Transactional(readOnly = true)
    public List<Session> getAllSessionsByUser(Long idUser) {
        return sessionRepository.findByIdUser(idUser)
                .stream()
                .map(sessionRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Get session by ID
     */
    @Transactional(readOnly = true)
    public Optional<Session> getSessionById(Long idSession) {
        return sessionRepository.findById(idSession)
                .map(sessionRepository::toDomain);
    }
    
    /**
     * Count active sessions for user
     */
    @Transactional(readOnly = true)
    public Long countActiveSessionsByUser(Long idUser) {
        return sessionRepository.countByIdUserAndStatus(idUser, "Active");
    }
    
    /**
     * Get most recent session for user
     */
    @Transactional(readOnly = true)
    public Optional<Session> getMostRecentSessionByUser(Long idUser) {
        List<SessionJpaEntity> sessions = sessionRepository.findMostRecentSessionByUser(idUser);
        if (!sessions.isEmpty()) {
            return Optional.of(sessionRepository.toDomain(sessions.get(0)));
        }
        return Optional.empty();
    }
    
    /**
     * Get sessions by date range
     */
    @Transactional(readOnly = true)
    public List<Session> getSessionsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return sessionRepository.findByDateLoginBetween(startDate, endDate)
                .stream()
                .map(sessionRepository::toDomain)
                .collect(Collectors.toList());
    }
    
    /**
     * Check if user has active session
     */
    @Transactional(readOnly = true)
    public boolean hasActiveSession(Long idUser) {
        return countActiveSessionsByUser(idUser) > 0;
    }
    
    /**
     * Save session
     */
    private Session save(Session session) {
        SessionJpaEntity jpaEntity = sessionRepository.toJpaEntity(session);
        SessionJpaEntity saved = sessionRepository.save(jpaEntity);
        return sessionRepository.toDomain(saved);
    }
}
