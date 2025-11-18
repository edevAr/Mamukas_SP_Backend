package com.mamukas.erp.erpbackend.application.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    @Value("${app.activation.base-url}")
    private String baseUrl;

    public void sendAccountActivationEmail(String toEmail, String activationToken) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("Activa tu cuenta - ERP System");

            String activationUrl = baseUrl + "/auth/activate?token=" + activationToken;
            
            String htmlContent = createActivationEmailTemplate(activationUrl);
            helper.setText(htmlContent, true);

            mailSender.send(message);
        } catch (MessagingException e) {
            throw new RuntimeException("Error al enviar el email de activación", e);
        }
    }

    public void sendPasswordResetEmail(String toEmail, String resetToken) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("Recuperar contraseña - ERP System");

            String resetUrl = baseUrl + "/auth/reset-password?token=" + resetToken;
            
            String htmlContent = createPasswordResetEmailTemplate(resetUrl);
            helper.setText(htmlContent, true);

            mailSender.send(message);
        } catch (MessagingException e) {
            throw new RuntimeException("Error al enviar el email de recuperación", e);
        }
    }

    public void sendSimpleEmail(String toEmail, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromEmail);
        message.setTo(toEmail);
        message.setSubject(subject);
        message.setText(text);
        mailSender.send(message);
    }

    private String createActivationEmailTemplate(String activationUrl) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>Activación de Cuenta</title>
                <style>
                    body { font-family: Arial, sans-serif; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background-color: #007bff; color: white; padding: 20px; text-align: center; }
                    .content { padding: 20px; }
                    .button { 
                        display: inline-block; 
                        padding: 12px 24px; 
                        background-color: #28a745; 
                        color: white; 
                        text-decoration: none; 
                        border-radius: 5px; 
                        margin: 20px 0;
                    }
                    .footer { padding: 20px; text-align: center; color: #666; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>¡Bienvenido al ERP System!</h1>
                    </div>
                    <div class="content">
                        <h2>Activa tu cuenta</h2>
                        <p>Gracias por registrarte en nuestro sistema ERP. Para completar tu registro y activar tu cuenta, haz clic en el botón de abajo:</p>
                        <p style="text-align: center;">
                            <a href="%s" class="button">Activar Cuenta</a>
                        </p>
                        <p>Si no puedes hacer clic en el botón, copia y pega el siguiente enlace en tu navegador:</p>
                        <p style="word-break: break-all;">%s</p>
                        <p><strong>Importante:</strong> Este enlace expirará en 24 horas por motivos de seguridad.</p>
                    </div>
                    <div class="footer">
                        <p>Si no solicitaste esta activación, puedes ignorar este email.</p>
                        <p>&copy; 2024 ERP System. Todos los derechos reservados.</p>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(activationUrl, activationUrl);
    }

    private String createPasswordResetEmailTemplate(String resetUrl) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>Recuperar Contraseña</title>
                <style>
                    body { font-family: Arial, sans-serif; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background-color: #dc3545; color: white; padding: 20px; text-align: center; }
                    .content { padding: 20px; }
                    .button { 
                        display: inline-block; 
                        padding: 12px 24px; 
                        background-color: #007bff; 
                        color: white; 
                        text-decoration: none; 
                        border-radius: 5px; 
                        margin: 20px 0;
                    }
                    .footer { padding: 20px; text-align: center; color: #666; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>Recuperar Contraseña</h1>
                    </div>
                    <div class="content">
                        <h2>Solicitud de cambio de contraseña</h2>
                        <p>Hemos recibido una solicitud para cambiar la contraseña de tu cuenta. Si fuiste tú quien lo solicitó, haz clic en el botón de abajo:</p>
                        <p style="text-align: center;">
                            <a href="%s" class="button">Cambiar Contraseña</a>
                        </p>
                        <p>Si no puedes hacer clic en el botón, copia y pega el siguiente enlace en tu navegador:</p>
                        <p style="word-break: break-all;">%s</p>
                        <p><strong>Importante:</strong> Este enlace expirará en 1 hora por motivos de seguridad.</p>
                    </div>
                    <div class="footer">
                        <p>Si no solicitaste este cambio, puedes ignorar este email. Tu contraseña permanecerá sin cambios.</p>
                        <p>&copy; 2024 ERP System. Todos los derechos reservados.</p>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(resetUrl, resetUrl);
    }
}
