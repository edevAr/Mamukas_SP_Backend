package com.mamukas.erp.erpbackend.application.services;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

@Service
public class JwtService {

    @Value("${app.jwt.secret}")
    private String jwtSecret;

    @Value("${app.jwt.access-expiration}")
    private Long jwtExpiration;

    @Value("${app.jwt.refresh-expiration}")
    private Long refreshTokenExpiration;

    private SecretKey getSigningKey() {
        byte[] keyBytes = Base64.getDecoder().decode(jwtSecret);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public String generateAccessToken(Long idUser, String username, String email, String role, List<String> permissions) {
        return generateAccessToken(idUser, username, email, role, permissions, null);
    }

    public String generateAccessToken(Long idUser, String username, String email, String role, List<String> permissions, Long sessionId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("idUser", idUser);
        claims.put("username", username);
        claims.put("email", email);
        claims.put("role", role);
        claims.put("permissions", permissions);
        if (sessionId != null) {
            claims.put("sessionId", sessionId);
        }
        
        return Jwts.builder()
                .claims(claims)
                .subject(username)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + jwtExpiration))
                .signWith(getSigningKey())
                .compact();
    }

    public String generateRefreshToken(Long idUser, String role, List<String> permissions) {
        return generateRefreshToken(idUser, role, permissions, null);
    }

    public String generateRefreshToken(Long idUser, String role, List<String> permissions, Long sessionId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("idUser", idUser);
        claims.put("role", role);
        claims.put("permissions", permissions);
        claims.put("tokenType", "refresh");
        if (sessionId != null) {
            claims.put("sessionId", sessionId);
        }
        
        return Jwts.builder()
                .claims(claims)
                .subject(idUser.toString())
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + refreshTokenExpiration))
                .signWith(getSigningKey())
                .compact();
    }

    public Claims extractClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public String extractUsername(String token) {
        return extractClaims(token).getSubject();
    }

    public Long extractIdUser(String token) {
        return extractClaims(token).get("idUser", Long.class);
    }

    public Long extractSessionId(String token) {
        return extractClaims(token).get("sessionId", Long.class);
    }

    public String extractRole(String token) {
        return extractClaims(token).get("role", String.class);
    }

    @SuppressWarnings("unchecked")
    public List<String> extractPermissions(String token) {
        return extractClaims(token).get("permissions", List.class);
    }

    public boolean isTokenValid(String token, String username) {
        try {
            final String tokenUsername = extractUsername(token);
            return tokenUsername.equals(username) && !isTokenExpired(token);
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isTokenExpired(String token) {
        return extractClaims(token).getExpiration().before(new Date());
    }
}
