package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.LoginRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.request.RegisterRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.request.RefreshTokenRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.request.ForgotPasswordRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.request.ResetPasswordRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.RegisterResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.LoginTokenResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.RefreshTokenResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.MessageResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.ErrorResponseDto;
import com.mamukas.erp.erpbackend.application.services.AuthService;
import com.mamukas.erp.erpbackend.application.exception.UserNotActivatedException;
import com.mamukas.erp.erpbackend.application.exception.AccountInactiveException;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<RegisterResponseDto> register(@Valid @RequestBody RegisterRequestDto request) {
        try {
            RegisterResponseDto response = authService.register(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            RegisterResponseDto errorResponse = new RegisterResponseDto(
                null, null, null, null, null, e.getMessage()
            );
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequestDto request) {
        try {
            // Use device and IP from the request DTO
            LoginTokenResponseDto response = authService.login(request, request.getDevice(), request.getIp());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (UserNotActivatedException e) {
            // Usuario con status 0 (pendiente de activación)
            ErrorResponseDto errorResponse = new ErrorResponseDto(
                "user_not_activated",
                "Your account is pending activation. Please verify your email."
            );
            return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);
        } catch (AccountInactiveException e) {
            // Usuario con status 2 (inactivo)
            ErrorResponseDto errorResponse = new ErrorResponseDto(
                "account_inactive", 
                "Your account has been deactivated. Contact support."
            );
            return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);
        } catch (RuntimeException e) {
            // Otros errores (credenciales incorrectas, etc.)
            ErrorResponseDto errorResponse = new ErrorResponseDto(
                "invalid_credentials",
                "Invalid username or password."
            );
            return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);
        }
    }

    @GetMapping("/activate")
    public ResponseEntity<String> activateAccount(@RequestParam("token") String token) {
        try {
            MessageResponseDto response = authService.activateAccount(token);
            
            // Devolver una página HTML simple en lugar de JSON
            String htmlResponse = """
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Activación de Cuenta</title>
                    <style>
                        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
                        .success { color: green; }
                        .container { max-width: 500px; margin: 0 auto; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <h1 class="success">✅ ¡Cuenta Activada!</h1>
                        <p>%s</p>
                        <p>Ya puedes cerrar esta ventana e iniciar sesión.</p>
                    </div>
                </body>
                </html>
                """.formatted(response.getMessage());
                
            return ResponseEntity.ok()
                .header("Content-Type", "text/html; charset=utf-8")
                .body(htmlResponse);
        } catch (RuntimeException e) {
            String errorHtml = """
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Error de Activación</title>
                    <style>
                        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
                        .error { color: red; }
                        .container { max-width: 500px; margin: 0 auto; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <h1 class="error">❌ Error de Activación</h1>
                        <p>%s</p>
                        <p>Por favor, contacta al soporte técnico.</p>
                    </div>
                </body>
                </html>
                """.formatted(e.getMessage());
                
            return ResponseEntity.badRequest()
                .header("Content-Type", "text/html; charset=utf-8")
                .body(errorHtml);
        }
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<RefreshTokenResponseDto> refreshToken(@Valid @RequestBody RefreshTokenRequestDto request) {
        try {
            RefreshTokenResponseDto response = authService.refreshToken(request);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            RefreshTokenResponseDto errorResponse = new RefreshTokenResponseDto(null, null);
            return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);
        }
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<MessageResponseDto> forgotPassword(@Valid @RequestBody ForgotPasswordRequestDto request) {
        try {
            MessageResponseDto response = authService.forgotPassword(request);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            MessageResponseDto errorResponse = new MessageResponseDto(e.getMessage());
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<MessageResponseDto> resetPassword(@Valid @RequestBody ResetPasswordRequestDto request) {
        try {
            MessageResponseDto response = authService.resetPassword(request);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            MessageResponseDto errorResponse = new MessageResponseDto(e.getMessage());
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<MessageResponseDto> logout(@RequestHeader("Authorization") String authorizationHeader) {
        try {
            // Extract token from Authorization header (format: "Bearer <token>")
            if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
                return new ResponseEntity<>(
                    new MessageResponseDto("Token de autorización requerido en el header Authorization"),
                    HttpStatus.BAD_REQUEST
                );
            }
            
            String token = authorizationHeader.substring(7); // Remove "Bearer " prefix
            MessageResponseDto response = authService.logout(token);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            MessageResponseDto errorResponse = new MessageResponseDto("Error al cerrar sesión: " + e.getMessage());
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/validate-token")
    public ResponseEntity<MessageResponseDto> validateToken(@RequestParam("token") String token) {
        try {
            // Esta validación se puede implementar según el tipo de token
            return new ResponseEntity<>(
                new MessageResponseDto("Token válido"),
                HttpStatus.OK
            );
        } catch (RuntimeException e) {
            return new ResponseEntity<>(
                new MessageResponseDto("Token inválido"),
                HttpStatus.BAD_REQUEST
            );
        }
    }
}
