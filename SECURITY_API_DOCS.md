# API Security Documentation

## Autenticación JWT para Todos los Endpoints

**¡IMPORTANTE!** Todos los controladores de la aplicación ahora requieren autenticación JWT para acceder a sus endpoints, excepto los endpoints de autenticación.

### 🔐 **Endpoints que Requieren Autenticación:**

**Gestión de Órdenes:**
- `/api/detail-orders/**` - Gestión de detalles de órdenes
- `/api/entry-orders/**` - Gestión de órdenes de entrada (compras)
- `/api/exit-orders/**` - Gestión de órdenes de salida (ventas)

**Gestión de Inventario:**
- `/api/products/**` - Gestión de productos
- `/api/packs/**` - Gestión de paquetes
- `/api/boxes/**` - Gestión de cajas

**Gestión de Relaciones Comerciales:**
- `/api/providers/**` - Gestión de proveedores
- `/api/customers/**` - Gestión de clientes

**Gestión de Ubicaciones:**
- `/api/warehouses/**` - Gestión de almacenes
- `/api/stores/**` - Gestión de tiendas
- `/api/warehouse-stores/**` - Relaciones almacén-tienda

**Gestión de Personal:**
- `/api/employee-warehouses/**` - Empleados de almacén
- `/api/employee-stores/**` - Empleados de tienda

**Gestión de Ventas:**
- `/api/sales/**` - Gestión de ventas

**Gestión de Usuarios y Permisos:**
- `/api/users/**` - Gestión de usuarios
- `/api/roles/**` - Gestión de roles
- `/api/permissions/**` - Gestión de permisos
- `/api/role-permissions/**` - Asignación de permisos a roles

**Gestión de Empresa:**
- `/api/companies/**` - Información de empresa

### 🌐 **Endpoints Públicos (No Requieren Token):**

- `/api/auth/**` - Endpoints de autenticación y registro
- `/h2-console/**` - Consola H2 para desarrollo

### 🔑 **Cómo Obtener un Token JWT:**

1. **Login del usuario:**
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "usuario@ejemplo.com",
  "password": "contraseña"
}
```

2. **Respuesta con token:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "refreshToken": "...",
  "expiresIn": 3600
}
```

### 📡 **Usar el Token en Requests:**

Para acceder a CUALQUIER endpoint protegido, incluye el token en el header `Authorization`:

```bash
# Ejemplo: Crear un producto
POST /api/products
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "name": "Producto Test",
  "price": 99.99,
  "status": "Active"
}
```

```bash
# Ejemplo: Obtener usuarios
GET /api/users
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### ⚠️ **Respuestas de Error de Autenticación:**

**Sin token o token inválido:**
```
HTTP 401 Unauthorized
```

**Token expirado:**
```
HTTP 401 Unauthorized
```

### 🔧 **Configuración de Seguridad:**

- **Filtro JWT**: `JwtAuthenticationFilter` valida automáticamente los tokens
- **Configuración**: `SecurityConfig` requiere autenticación para todos los `/api/**` excepto `/api/auth/**`
- **Anotaciones**: `@PreAuthorize("hasRole('USER')")` en TODOS los controladores excepto `AuthController`

### 📝 **Ejemplo Completo con cURL:**

```bash
# 1. Hacer login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"usuario@ejemplo.com","password":"contraseña"}'

# 2. Usar el token para cualquier operación
curl -X GET http://localhost:8080/api/products \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

curl -X POST http://localhost:8080/api/customers \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"name":"Cliente Test","nit":"123456789"}'
```

### 🔍 **Validaciones Implementadas:**

- **Token válido**: El token debe ser válido y no expirado
- **Usuario existente**: El usuario del token debe existir en la base de datos
- **Rol USER**: El usuario debe tener al menos el rol 'USER'
- **Headers correctos**: El token debe enviarse como `Bearer TOKEN` en el header `Authorization`
- **Cobertura completa**: Todos los endpoints de la API requieren autenticación excepto los de auth

### 🛡️ **Controladores Protegidos (19 total):**

✅ **DetailOrderController**, **EntryOrderController**, **ExitOrderController**
✅ **ProductController**, **PackController**, **BoxController**  
✅ **ProviderController**, **CustomerController**
✅ **WarehouseController**, **StoreController**, **WarehouseStoreController**
✅ **EmployeeWarehouseController**, **EmployeeStoreController**
✅ **SaleController**
✅ **UserController**
✅ **RoleController**, **PermissionController**, **RolePermissionController**
✅ **CompanyController**

🌐 **Sin Protección:**
- **AuthController** (público por diseño y seguridad)

### 🔍 **Análisis de Seguridad del AuthController**

**¿Por qué AuthController es público?**
- ✅ **Requisito lógico**: Sin token no puedes hacer login
- ✅ **Estándar de industria**: Los endpoints de autenticación siempre son públicos
- ✅ **Funcionalidad esencial**: Registro, login, recuperación de contraseña

**Endpoints públicos del AuthController:**
```
POST /api/auth/register     - Registro de usuarios
POST /api/auth/login        - Autenticación
GET  /api/auth/activate     - Activación de cuenta
POST /api/auth/refresh-token - Renovación de tokens
POST /api/auth/forgot-password - Recuperación de contraseña
POST /api/auth/reset-password - Reseteo de contraseña  
POST /api/auth/logout       - Cierre de sesión
GET  /api/auth/validate-token - Validación de token
```

### 🛡️ **Medidas de Seguridad Implementadas:**

**Validaciones de Datos:**
- ✅ `@Valid` annotations en todos los DTOs
- ✅ Validación de formato de email
- ✅ Validación de longitud de contraseña

**Control de Estados:**
- ✅ Verificación de cuenta activada
- ✅ Control de estado de usuario (Activo/Inactivo/Pendiente)
- ✅ Manejo de excepciones específicas

**Seguridad de Contraseñas:**
- ✅ BCrypt hashing
- ✅ No exposición de contraseñas en logs
- ✅ Validación de complejidad (implementar si no existe)

### ⚠️ **Riesgos Potenciales y Mitigaciones:**

**1. Ataques de Fuerza Bruta:**
- 🔴 **Riesgo**: Intentos masivos de login
- ✅ **Mitigación**: Rate limiting (recomendado implementar)

**2. Spam de Registros:**
- 🔴 **Riesgo**: Creación masiva de cuentas
- ✅ **Mitigación**: Captcha, validación de email

**3. Enumeración de Usuarios:**
- 🔴 **Riesgo**: Descubrir emails válidos
- ✅ **Mitigación**: Mensajes de error genéricos

**Recomendaciones adicionales:**
```java
// Rate Limiting (opcional)
@RateLimited(maxRequests = 5, window = "1m")
@PostMapping("/login")

// IP Blocking después de X intentos fallidos
// Captcha después de 3 intentos fallidos
// Logs de seguridad para monitoreo
```