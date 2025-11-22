import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static List<String> _permissions = [];
  static String? _accessToken;
  static String? _username;
  static bool _isAuthenticated = false;

  // Configurar token de acceso y extraer permisos
  static void setAccessToken(String token) {
    try {
      _accessToken = token;
      _isAuthenticated = true;
      
      // Verificar si el token es válido
      if (!JwtDecoder.isExpired(token)) {
        final payload = JwtDecoder.decode(token);
        
        // Extraer permisos del payload
        _permissions = List<String>.from(payload['permissions'] ?? []);
        
        // Extraer información adicional del usuario
        _username = payload['username'] ?? payload['sub'] ?? 'Usuario';
        
        print('Token configurado exitosamente');
        print('Usuario: $_username');
        print('Permisos: $_permissions');
      } else {
        print('Token expirado');
        _clearAuth();
      }
    } catch (e) {
      print('Error al decodificar token: $e');
      _clearAuth();
    }
  }

  // Limpiar información de autenticación
  static void _clearAuth() {
    _accessToken = null;
    _permissions = [];
    _username = null;
    _isAuthenticated = false;
  }

  // Cerrar sesión
  static void logout() {
    _clearAuth();
    print('Sesión cerrada');
  }

  // Verificar si el usuario está autenticado
  static bool get isAuthenticated => _isAuthenticated && _accessToken != null;

  // Obtener nombre de usuario
  static String? get username => _username;

  // Obtener token de acceso
  static String? get accessToken => _accessToken;

  // Obtener lista de permisos
  static List<String> get permissions => List.unmodifiable(_permissions);

  // Verificar si tiene un permiso específico
  static bool hasPermission(String permission) {
    return _permissions.contains(permission);
  }

  // Verificar si es administrador
  static bool get isAdmin => hasAllPermissions(["INVENTORY_*","USER_*","PRODUCTS_*","STORES_*","WAREHOUSES_*","SALES_*"]);

  // Verificar si es manager
  static bool get isManager => hasPermission('MANAGER');

  // Obtener el rol del usuario desde el token
  static String? get role {
    if (_accessToken == null) return null;
    try {
      final payload = JwtDecoder.decode(_accessToken!);
      return payload['role']?.toString();
    } catch (e) {
      return null;
    }
  }

  // Verificar si es Employee
  static bool get isEmployee {
    final userRole = role;
    return userRole != null && (userRole.toLowerCase() == 'employee' || userRole.toLowerCase() == 'empleado');
  }

  // Verificar múltiples permisos (OR - cualquiera)
  static bool hasAnyPermission(List<String> permissions) {
    return permissions.any((p) => _permissions.contains(p));
  }

  // Verificar múltiples permisos (AND - todos)
  static bool hasAllPermissions(List<String> permissions) {
    return permissions.every((p) => _permissions.contains(p));
  }

  // Permisos específicos del sistema
  static bool get canManageWarehouses => 
      hasAnyPermission(['WAREHOUSES_*', 'ADMIN']);

  static bool get canManageStores => 
      hasAnyPermission(['STORES_*', 'MANAGER', 'ADMIN']);

  static bool get canManageProducts => 
      hasAnyPermission(['PRODUCTS_*', 'MANAGER', 'ADMIN']);

  static bool get canViewReports => 
      hasAnyPermission(['REPORTS_VIEW', 'MANAGER', 'ADMIN']);

  static bool get canEditProducts => 
      hasAnyPermission(['PRODUCT_EDIT', 'MANAGER', 'ADMIN']);

  static bool get canDeleteProducts => 
      hasAnyPermission(['PRODUCT_DELETE', 'ADMIN']);

  static bool get canManageUsers => 
      hasPermission('ADMIN');

  static bool get canAccessAdminPanel => 
      hasPermission('ADMIN');

  // Verificar si el token está por expirar (próximos 5 minutos)
  static bool get isTokenExpiringSoon {
    if (_accessToken == null) return false;
    
    try {
      final remainingTime = JwtDecoder.getRemainingTime(_accessToken!);
      return remainingTime.inMinutes <= 5;
    } catch (e) {
      return true;
    }
  }

  // Verificar si el token ha expirado
  static bool get isTokenExpired {
    if (_accessToken == null) return true;
    
    try {
      return JwtDecoder.isExpired(_accessToken!);
    } catch (e) {
      return true;
    }
  }

  // Obtener información del token para debugging
  static Map<String, dynamic> getTokenInfo() {
    if (_accessToken == null) return {};
    
    try {
      return JwtDecoder.decode(_accessToken!);
    } catch (e) {
      return {};
    }
  }

  // Obtener email del usuario desde el token
  static String? get email {
    if (_accessToken == null) return null;
    try {
      final payload = JwtDecoder.decode(_accessToken!);
      return payload['email']?.toString();
    } catch (e) {
      return null;
    }
  }

  // Obtener idUser del usuario desde el token
  static int? get idUser {
    if (_accessToken == null) return null;
    try {
      final payload = JwtDecoder.decode(_accessToken!);
      final idUserValue = payload['idUser'];
      if (idUserValue is int) return idUserValue;
      if (idUserValue is num) return idUserValue.toInt();
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obtener nombre completo del usuario (si está disponible en el token)
  static String? get fullName {
    if (_accessToken == null) return null;
    try {
      final payload = JwtDecoder.decode(_accessToken!);
      final name = payload['name']?.toString();
      final lastName = payload['lastName']?.toString();
      if (name != null && lastName != null) {
        return '$name $lastName';
      }
      return name ?? lastName ?? _username;
    } catch (e) {
      return _username;
    }
  }

  // Obtener nombre del rol formateado
  static String get roleDisplayName {
    if (isAdmin) return 'Administrador';
    if (isManager) return 'Gerente';
    if (isEmployee) return 'Empleado';
    final userRole = role;
    if (userRole != null) {
      return userRole.substring(0, 1).toUpperCase() + userRole.substring(1).toLowerCase();
    }
    return 'Usuario';
  }

  // Obtener iniciales del usuario para el avatar
  static String get initials {
    final name = fullName ?? _username ?? 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Simular configuración de permisos para demo (temporal)
  static void setDemoPermissions(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        _permissions = [
          "INVENTORY_*",
          "USER_*",
          "PRODUCTS_*",
          "STORES_*",
          "WAREHOUSES_*",
          "SALES_*"
        ];
        break;
      case 'manager':
        _permissions = [
          'MANAGER',
          'STORE_MANAGEMENT',
          'PRODUCT_MANAGEMENT',
          'PRODUCT_EDIT',
          'REPORTS_VIEW',
        ];
        break;
      case 'employee':
        _permissions = [
          'PRODUCT_VIEW',
          'STORE_VIEW',
        ];
        break;
      case 'demo':
        _permissions = [
          'PRODUCT_VIEW',
          'STORE_VIEW',
          'WAREHOUSE_VIEW',
        ];
        break;
      default:
        _permissions = ['PRODUCT_VIEW'];
    }
    _username = userType;
    _isAuthenticated = true;
    
    print('Permisos demo configurados para $userType: $_permissions');
  }
}