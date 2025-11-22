import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io' show Platform, NetworkInterface, InternetAddressType;
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:universal_html/html.dart' as html;
import '../../core/services/auth_service.dart';
import '../../core/constants/api_constants.dart';

class DemoLoginPage extends StatefulWidget {
  const DemoLoginPage({super.key});

  @override
  State<DemoLoginPage> createState() => _DemoLoginPageState();
}

class _DemoLoginPageState extends State<DemoLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (kIsWeb) {
      final webBrowserInfo = await deviceInfo.webBrowserInfo;
      return 'browser (${webBrowserInfo.browserName.name})';
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return 'Android (${androidInfo.model})';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return 'iOS (${iosInfo.model})';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown';
    }
  }

  Future<String> _getIpAddress() async {
    try {
      if (kIsWeb) {
        // Para web, intentar obtener IP usando un servicio externo
        final response = await http.get(
          Uri.parse('https://api.ipify.org?format=json'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['ip'] ?? 'unknown';
        }
      } else {
        // Para móviles y desktop, usar NetworkInterface
        final interfaces = await NetworkInterface.list();
        for (final interface in interfaces) {
          for (final address in interface.addresses) {
            if (!address.isLoopback && address.type == InternetAddressType.IPv4) {
              return address.address;
            }
          }
        }
      }
    } catch (e) {
      print('Error getting IP: $e');
    }
    return 'unknown';
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener información del dispositivo e IP
      final device = await _getDeviceInfo();
      final ip = await _getIpAddress();

      // Crear el JSON para enviar al API
      final loginData = {
        'usernameOrEmail': _usernameController.text.trim(),
        'password': _passwordController.text,
        'device': device,
        'ip': ip,
      };

      print('Sending login data: ${json.encode(loginData)}');

      // Hacer la petición POST al endpoint
      final response = await http.post(
        Uri.parse(ApiConstants.authLogin),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(loginData),
      ).timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          // Login exitoso
          final responseData = json.decode(response.body);
          
          // Extraer accessToken del response
          final accessToken = responseData['accessToken'];
          
          if (accessToken != null) {
            // Configurar token y permisos en AuthService
            AuthService.setAccessToken(accessToken);
            
            print('Permisos configurados: ${AuthService.permissions}');
            print('Es admin: ${AuthService.isAdmin}');
          } else {
            // Fallback para demo sin JWT real
            final username = _usernameController.text.trim().toLowerCase();
            AuthService.setDemoPermissions(username);
            
            print('Configuración demo para $username');
            print('Permisos: ${AuthService.permissions}');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Inicio de sesión exitoso - ${AuthService.username}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Navegar a la demo
          Navigator.of(context).pushReplacementNamed('/demo');
        } else {
          // Error de autenticación
          String errorMessage = 'Error de autenticación';
          
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          } catch (e) {
            // Si no se puede parsear la respuesta, usar mensaje por defecto
            errorMessage = 'Credenciales incorrectas (${response.statusCode})';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Error de conexión';
        
        if (e.toString().contains('SocketException') || 
            e.toString().contains('Connection refused')) {
          errorMessage = 'No se puede conectar al servidor. Verifica la conexión a internet.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Tiempo de espera agotado. Verifica la conexión.';
        } else {
          errorMessage = 'Error de conexión: ${e.toString()}';
        }
        
        print('Login error: $e');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock_reset,
                color: const Color(0xFF007AFF),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Recuperar Contraseña',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                emailController.dispose();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (emailController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Se ha enviado un enlace de recuperación a ${emailController.text}',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
                emailController.dispose();
              },
              child: const Text(
                'Enviar',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateAccountDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: const Color(0xFF007AFF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Campo nombre completo
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      
                      // Campo email
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      
                      // Campo contraseña
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey[500],
                                size: 20,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      
                      // Campo confirmar contraseña
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirmar contraseña',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey[500],
                                size: 20,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  obscureConfirmPassword = !obscureConfirmPassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    nameController.dispose();
                    emailController.dispose();
                    passwordController.dispose();
                    confirmPasswordController.dispose();
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Validaciones básicas
                    if (nameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty ||
                        passwordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor completa todos los campos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    if (passwordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Las contraseñas no coinciden'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    if (passwordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La contraseña debe tener al menos 6 caracteres'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cuenta creada exitosamente para ${nameController.text}',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    
                    nameController.dispose();
                    emailController.dispose();
                    passwordController.dispose();
                    confirmPasswordController.dispose();
                  },
                  child: const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo y título
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'Mamuka ERP',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        letterSpacing: -0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Campo de usuario
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Usuario',
                          hintText: 'admin o demo',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu usuario';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo de contraseña
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: '123456',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.grey[500],
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey[500],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón de login
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF007AFF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botones secundarios
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Botón ¿Olvidaste tu contraseña?
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: const Color(0xFF007AFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Botón Crear cuenta
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF007AFF),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _showCreateAccountDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Crear cuenta',
                          style: TextStyle(
                            color: const Color(0xFF007AFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Información de credenciales demo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF007AFF).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: const Color(0xFF007AFF),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Credenciales de Demo',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF007AFF),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Usuario: admin o demo\nContraseña: 123456',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}