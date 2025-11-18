package com.mamukas.erp.erpbackend.application.services;

import com.mamukas.erp.erpbackend.application.dtos.request.*;
import com.mamukas.erp.erpbackend.application.dtos.response.*;
import com.mamukas.erp.erpbackend.application.services.UserService;
import com.mamukas.erp.erpbackend.application.services.RoleService;
import com.mamukas.erp.erpbackend.application.services.RolePermissionService;
import com.mamukas.erp.erpbackend.application.services.SessionService;
import com.mamukas.erp.erpbackend.application.exception.UserNotActivatedException;
import com.mamukas.erp.erpbackend.application.exception.AccountInactiveException;
import com.mamukas.erp.erpbackend.domain.entities.*;
import com.mamukas.erp.erpbackend.domain.entities.auth.*;
import com.mamukas.erp.erpbackend.infrastructure.persistence.entity.*;
import com.mamukas.erp.erpbackend.infrastructure.persistence.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class AuthService {

    @Autowired
    private UserService userService;

    @Autowired
    private RoleService roleService;

    @Autowired
    private RolePermissionService rolePermissionService;

    @Autowired
    private SessionService sessionService;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private EmailService emailService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private AccountActivationTokenJpaRepository activationTokenRepository;

    @Autowired
    private PasswordResetTokenJpaRepository passwordResetTokenRepository;

    @Autowired
    private RefreshTokenJpaRepository refreshTokenRepository;

    @Value("${app.activation.token-expiration}")
    private Long activationTokenExpiration;

    @Value("${app.password-reset.token-expiration}")
    private Long resetTokenExpiration;

    @Value("${app.jwt.refresh-expiration}")
    private Long refreshTokenExpiration;

    public RegisterResponseDto register(RegisterRequestDto request) {
        // Validar que las contraseñas coincidan
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new RuntimeException("Las contraseñas no coinciden");
        }

        // Validar que el usuario no exista
        if (userService.existsByEmail(request.getEmail())) {
            throw new RuntimeException("El email ya está registrado");
        }

        if (userService.existsByUsername(request.getUsername())) {
            throw new RuntimeException("El nombre de usuario ya está en uso");
        }

        // Obtener rol "Customer" por defecto para todos los nuevos usuarios
        Long roleId = null;
        try {
            Role defaultRole = roleService.findByRoleName("Customer")
                .orElseThrow(() -> new RuntimeException("Default role 'Customer' not found"));
            roleId = defaultRole.getIdRole();
        } catch (Exception e) {
            throw new RuntimeException("Error asignando rol por defecto: " + e.getMessage());
        }

        // Crear usuario pendiente de activación
        User user = new User(
            request.getUsername(),
            request.getEmail(),
            passwordEncoder.encode(request.getPassword()),
            request.getName(),
            request.getLastName(),
            request.getAge(),
            request.getCi(),
            0, // Status 0 = Pendiente activación
            roleId // Asignar rol "Customer" por defecto
        );

        User savedUser = userService.save(user);

        // Crear y enviar token de activación
        String activationToken = generateActivationToken(request.getEmail());
        emailService.sendAccountActivationEmail(request.getEmail(), activationToken);

        return new RegisterResponseDto(
            savedUser.getIdUser(),
            savedUser.getUsername(),
            savedUser.getEmail(),
            savedUser.getName(),
            savedUser.getLastName(),
            "Usuario registrado exitosamente. Revisa tu email para activar tu cuenta."
        );
    }

    public LoginTokenResponseDto login(LoginRequestDto request) {
        return login(request, null, null);
    }

    public LoginTokenResponseDto login(LoginRequestDto request, String device, String ip) {
        try {
            System.out.println("=== LOGIN DEBUG: Input received ===");
            System.out.println("UsernameOrEmail: " + request.getUsernameOrEmail());
            
            // Buscar usuario por email o username
            System.out.println("=== LOGIN STEP 1: Searching user ===");
            java.util.Optional<User> userByEmail = userService.findByEmail(request.getUsernameOrEmail());
            java.util.Optional<User> userByUsername = userService.findByUsername(request.getUsernameOrEmail());
            
            User user = userByEmail.or(() -> userByUsername)
                    .orElseThrow(() -> new RuntimeException("Credenciales inválidas"));

            System.out.println("=== LOGIN STEP 2: User found - ID: " + user.getIdUser() + " ===");
            
            // Verificar el estado específico del usuario
            Integer userStatus = user.getStatus();
            
            if (userStatus == 0) {
                // Usuario pendiente de activación
                throw new UserNotActivatedException("Your account is pending activation. Please verify your email.");
            }
            
            if (userStatus == 2) {
                // Usuario inactivo
                throw new AccountInactiveException("Your account has been deactivated. Contact support.");
            }
            
            if (userStatus != 1) {
                // Estado desconocido
                throw new RuntimeException("Invalid account status. Contact support.");
            }

            System.out.println("=== LOGIN STEP 3: Creating session ===");
            
            // Crear sesión de login
            Session session = sessionService.createLoginSession(user.getIdUser(), device, ip);
            
            System.out.println("=== LOGIN STEP 4: Generating tokens ===");
            
            // Obtener el nombre del rol del usuario
            String roleName = "Unknown";
            if (user.getRoleId() != null) {
                try {
                    Role role = roleService.findById(user.getRoleId())
                        .orElse(null);
                    if (role != null) {
                        roleName = role.getRoleName();
                    }
                } catch (Exception e) {
                    System.out.println("Warning: Could not retrieve role name for user: " + e.getMessage());
                }
            }
            
            // Obtener los permisos del usuario
            List<String> userPermissions = getUserPermissions(user.getRoleId());
            
            // Generar tokens JWT reales con el rol, permisos y session ID incluidos
            String accessToken = jwtService.generateAccessToken(
                user.getIdUser(), 
                user.getUsername(), 
                user.getEmail(),
                roleName,
                userPermissions,
                session.getIdSession()
            );
            
            String refreshToken = jwtService.generateRefreshToken(
                user.getIdUser(), 
                roleName, 
                userPermissions,
                session.getIdSession()
            );
            
            System.out.println("=== LOGIN STEP 5: Tokens generated successfully ===");
            
            return new LoginTokenResponseDto(accessToken, refreshToken);
            
        } catch (Exception e) {
            System.out.println("ERROR EN LOGIN: " + e.getClass().getSimpleName() + " - " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    public MessageResponseDto activateAccount(String token) {
        AccountActivationTokenJpaEntity activationTokenEntity = activationTokenRepository
            .findByTokenAndUsed(token, false)
            .orElseThrow(() -> new RuntimeException("Token de activación inválido o ya usado"));

        AccountActivationToken activationToken = mapToAccountActivationTokenDomain(activationTokenEntity);

        if (!activationToken.isValid()) {
            throw new RuntimeException("El token de activación ha expirado");
        }

        // Buscar y activar usuario
        User user = userService.findByEmail(activationToken.getEmail())
            .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        user.setEmailVerified(true);
        user.activate(); // También activa el usuario

        userService.save(user);

        // Marcar token como usado
        activationTokenEntity.setUsed(true);
        activationTokenEntity.setUsedAt(LocalDateTime.now());
        activationTokenRepository.save(activationTokenEntity);

        return new MessageResponseDto("Cuenta activada exitosamente. Ya puedes iniciar sesión.");
    }

    public RefreshTokenResponseDto refreshToken(RefreshTokenRequestDto request) {
        RefreshTokenJpaEntity refreshTokenEntity = refreshTokenRepository
            .findByTokenAndRevoked(request.getRefreshToken(), false)
            .orElseThrow(() -> new RuntimeException("Refresh token inválido"));

        RefreshToken refreshToken = mapToRefreshTokenDomain(refreshTokenEntity);

        if (!refreshToken.isValid()) {
            throw new RuntimeException("Refresh token expirado");
        }

        User user = userService.findById(refreshToken.getUserId())
            .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // Revocar el token actual
        refreshTokenEntity.setRevoked(true);
        refreshTokenRepository.save(refreshTokenEntity);

        // Obtener el nombre del rol del usuario
        String roleName = "Unknown";
        if (user.getRoleId() != null) {
            try {
                Role role = roleService.findById(user.getRoleId())
                    .orElse(null);
                if (role != null) {
                    roleName = role.getRoleName();
                }
            } catch (Exception e) {
                System.out.println("Warning: Could not retrieve role name for user: " + e.getMessage());
            }
        }

        // Obtener los permisos del usuario
        List<String> userPermissions = getUserPermissions(user.getRoleId());

        // Generar nuevos tokens con permisos incluidos
        String newAccessToken = jwtService.generateAccessToken(
            user.getIdUser(), 
            user.getUsername(), 
            user.getEmail(),
            roleName,
            userPermissions
        );
        String newRefreshToken = generateAndSaveRefreshToken(user.getIdUser());

        return new RefreshTokenResponseDto(newAccessToken, newRefreshToken);
    }

    public MessageResponseDto forgotPassword(ForgotPasswordRequestDto request) {
        User user = userService.findByEmail(request.getEmail())
            .orElseThrow(() -> new RuntimeException("No existe un usuario con ese email"));

        // Invalidar tokens anteriores
        passwordResetTokenRepository.findByEmailAndUsed(request.getEmail(), false)
            .forEach(token -> {
                token.setUsed(true);
                passwordResetTokenRepository.save(token);
            });

        // Crear nuevo token de reset
        String resetToken = generatePasswordResetToken(request.getEmail());
        emailService.sendPasswordResetEmail(request.getEmail(), resetToken);

        return new MessageResponseDto("Se ha enviado un enlace de recuperación a tu email.");
    }

    public MessageResponseDto resetPassword(ResetPasswordRequestDto request) {
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new RuntimeException("Las contraseñas no coinciden");
        }

        PasswordResetTokenJpaEntity resetTokenEntity = passwordResetTokenRepository
            .findByTokenAndUsed(request.getToken(), false)
            .orElseThrow(() -> new RuntimeException("Token de reset inválido o ya usado"));

        PasswordResetToken resetToken = mapToPasswordResetTokenDomain(resetTokenEntity);

        if (!resetToken.isValid()) {
            throw new RuntimeException("El token de reset ha expirado");
        }

        // Cambiar contraseña del usuario
        User user = userService.findByEmail(resetToken.getEmail())
            .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        user.setPassword(passwordEncoder.encode(request.getPassword()));
        userService.save(user);

        // Marcar token como usado
        resetTokenEntity.setUsed(true);
        resetTokenEntity.setUsedAt(LocalDateTime.now());
        passwordResetTokenRepository.save(resetTokenEntity);

        // Revocar todos los refresh tokens del usuario
        refreshTokenRepository.findByIdUserAndRevoked(user.getIdUser(), false)
            .forEach(token -> {
                token.setRevoked(true);
                refreshTokenRepository.save(token);
            });

        return new MessageResponseDto("Contraseña cambiada exitosamente.");
    }

    public MessageResponseDto logout(Long userId) {
        // Cerrar todas las sesiones activas del usuario
        sessionService.deactivateUserSessions(userId);
        
        // Revocar todos los refresh tokens del usuario
        refreshTokenRepository.findByIdUserAndRevoked(userId, false)
            .forEach(token -> {
                token.setRevoked(true);
                refreshTokenRepository.save(token);
            });

        SecurityContextHolder.clearContext();
        return new MessageResponseDto("Sesión cerrada exitosamente.");
    }

    public MessageResponseDto logout(String token) {
        try {
            // Extraer el userId y sessionId del token JWT
            Long userId = jwtService.extractIdUser(token);
            Long sessionId = jwtService.extractSessionId(token);
            
            if (userId == null) {
                throw new RuntimeException("Token inválido: no se pudo extraer el ID del usuario");
            }
            
            if (sessionId != null) {
                // Cerrar sesión específica
                Session session = sessionService.deactivateSpecificSession(sessionId);
                if (session == null) {
                    throw new RuntimeException("No se encontró la sesión activa especificada");
                }
            } else {
                // Fallback: cerrar todas las sesiones del usuario si no hay sessionId
                sessionService.deactivateUserSessions(userId);
            }
            
            // Revocar todos los refresh tokens del usuario
            refreshTokenRepository.findByIdUserAndRevoked(userId, false)
                .forEach(refreshToken -> {
                    refreshToken.setRevoked(true);
                    refreshTokenRepository.save(refreshToken);
                });

            SecurityContextHolder.clearContext();
            return new MessageResponseDto("Sesión cerrada exitosamente.");
        } catch (Exception e) {
            throw new RuntimeException("Error al procesar el token: " + e.getMessage());
        }
    }

    // Métodos privados auxiliares
    private String generateActivationToken(String email) {
        // Invalidar tokens anteriores
        activationTokenRepository.findByEmailAndUsed(email, false)
            .forEach(token -> {
                token.setUsed(true);
                activationTokenRepository.save(token);
            });

        String token = UUID.randomUUID().toString();
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.plusSeconds(activationTokenExpiration);

        AccountActivationTokenJpaEntity tokenEntity = new AccountActivationTokenJpaEntity(
            token, email, false, now, expiresAt
        );

        activationTokenRepository.save(tokenEntity);
        return token;
    }

    private String generatePasswordResetToken(String email) {
        String token = UUID.randomUUID().toString();
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.plusSeconds(resetTokenExpiration);

        PasswordResetTokenJpaEntity tokenEntity = new PasswordResetTokenJpaEntity(
            token, email, false, now, expiresAt
        );

        passwordResetTokenRepository.save(tokenEntity);
        return token;
    }

    private String generateAndSaveRefreshToken(Long userId) {
        String token = UUID.randomUUID().toString();
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.plusSeconds(refreshTokenExpiration);

        RefreshTokenJpaEntity tokenEntity = new RefreshTokenJpaEntity(
            token, userId, expiresAt, now, false
        );

        refreshTokenRepository.save(tokenEntity);
        return token;
    }

    // Métodos de mapeo
    private AccountActivationToken mapToAccountActivationTokenDomain(AccountActivationTokenJpaEntity entity) {
        AccountActivationToken token = new AccountActivationToken();
        token.setId(entity.getIdActivationToken());
        token.setToken(entity.getToken());
        token.setEmail(entity.getEmail());
        token.setUsed(entity.getUsed());
        token.setCreatedAt(entity.getCreatedAt());
        token.setExpiryDate(entity.getExpiresAt());
        token.setUsedAt(entity.getUsedAt());
        return token;
    }

    private RefreshToken mapToRefreshTokenDomain(RefreshTokenJpaEntity entity) {
        RefreshToken token = new RefreshToken();
        token.setId(entity.getIdRefreshToken());
        token.setToken(entity.getToken());
        token.setUserId(entity.getIdUser());
        token.setExpiryDate(entity.getExpiresAt());
        token.setCreatedAt(entity.getCreatedAt());
        token.setRevoked(entity.getRevoked());
        return token;
    }

    private PasswordResetToken mapToPasswordResetTokenDomain(PasswordResetTokenJpaEntity entity) {
        PasswordResetToken token = new PasswordResetToken();
        token.setId(entity.getIdResetToken());
        token.setToken(entity.getToken());
        token.setEmail(entity.getEmail());
        token.setUsed(entity.getUsed());
        token.setCreatedAt(entity.getCreatedAt());
        token.setExpiryDate(entity.getExpiresAt());
        // Note: usedAt field not available in domain entity
        return token;
    }

    /**
     * Get user permissions based on role
     */
    private List<String> getUserPermissions(Long roleId) {
        try {
            if (roleId == null) {
                return List.of(); // Return empty list if no role
            }
            
            return rolePermissionService.getPermissionsByRole(roleId)
                .stream()
                .map(rolePermissionDto -> rolePermissionDto.getPermissionName())
                .filter(permissionName -> permissionName != null)
                .collect(Collectors.toList());
        } catch (Exception e) {
            System.out.println("Warning: Could not retrieve permissions for role " + roleId + ": " + e.getMessage());
            return List.of(); // Return empty list if error occurs
        }
    }
}
