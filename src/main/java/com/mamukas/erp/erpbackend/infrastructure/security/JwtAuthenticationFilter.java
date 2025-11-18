package com.mamukas.erp.erpbackend.infrastructure.security;

import com.mamukas.erp.erpbackend.application.services.JwtService;
import com.mamukas.erp.erpbackend.application.services.UserService;
import com.mamukas.erp.erpbackend.domain.entities.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtService jwtService;

    @Autowired
    private UserService userService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String username;

        System.out.println("=== JWT FILTER DEBUG ===");
        System.out.println("Request URL: " + request.getRequestURL());
        System.out.println("Auth Header: " + authHeader);

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            System.out.println("No auth header or not Bearer token, skipping authentication");
            filterChain.doFilter(request, response);
            return;
        }

        jwt = authHeader.substring(7);
        username = jwtService.extractUsername(jwt); // Este es el username, no el email
        
        System.out.println("Extracted username from JWT: " + username);
        System.out.println("Current authentication: " + SecurityContextHolder.getContext().getAuthentication());

        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            // Buscar usuario por username (que es lo que está en el subject del JWT)
            java.util.Optional<User> userOptional = this.userService.findByUsername(username);

            System.out.println("User found: " + userOptional.isPresent());
            
            if (userOptional.isPresent()) {
                User user = userOptional.get();
                boolean isTokenValid = jwtService.isTokenValid(jwt, username);
                System.out.println("Token valid: " + isTokenValid);
                
                if (isTokenValid) {
                    // Obtener permisos directamente del JWT en lugar de la BD
                    List<String> permissions = jwtService.extractPermissions(jwt);
                    System.out.println("Permissions from JWT: " + permissions);
                    
                    List<SimpleGrantedAuthority> authorities = permissions
                            .stream()
                            .map(SimpleGrantedAuthority::new)
                            .collect(Collectors.toList());
                    
                    // También agregar el rol desde el JWT
                    String roleName = jwtService.extractRole(jwt);
                    if (roleName != null) {
                        authorities.add(new SimpleGrantedAuthority("ROLE_" + roleName));
                        System.out.println("Added role: ROLE_" + roleName);
                    }

                    System.out.println("Total authorities: " + authorities);

                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            user,
                            null,
                            authorities
                    );
                    authToken.setDetails(
                            new WebAuthenticationDetailsSource().buildDetails(request)
                    );
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                    
                    System.out.println("Authentication set in SecurityContext");
                }
            } else {
                System.out.println("User not found for username: " + username);
            }
        } else {
            System.out.println("Username is null or authentication already set");
        }
        
        System.out.println("=== END JWT FILTER DEBUG ===");
        filterChain.doFilter(request, response);
    }
}
