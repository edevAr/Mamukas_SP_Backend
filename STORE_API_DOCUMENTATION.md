# Store and Employee-Store API Documentation

## Resumen
Se han creado dos nuevas entidades:
- **Store**: Gestión de tiendas con dirección y estado
- **Employee_Store**: Relación many-to-many entre empleados y tiendas

## Endpoints de Store

### 1. Crear Tienda
```http
POST /api/stores
Content-Type: application/json

{
    "address": "Av. Principal 123, Lima",
    "status": "Active"
}
```

### 2. Listar Todas las Tiendas
```http
GET /api/stores
```

### 3. Obtener Tienda por ID
```http
GET /api/stores/{id}
```

### 4. Listar Tiendas Activas
```http
GET /api/stores/active
```

### 5. Listar Tiendas por Estado
```http
GET /api/stores/status/{status}
```

### 6. Buscar Tiendas por Dirección
```http
GET /api/stores/search?address=Lima
```

### 7. Actualizar Tienda
```http
PUT /api/stores/{id}
Content-Type: application/json

{
    "address": "Nueva Dirección 456",
    "status": "Active"
}
```

### 8. Activar Tienda
```http
PUT /api/stores/{id}/activate
```

### 9. Desactivar Tienda
```http
PUT /api/stores/{id}/deactivate
```

### 10. Eliminar Tienda
```http
DELETE /api/stores/{id}
```

## Endpoints de Employee-Store

### 1. Asignar Empleado a Tienda
```http
POST /api/employee-stores
Content-Type: application/json

{
    "idUser": 1,
    "idStore": 1
}
```

### 2. Listar Tiendas de un Empleado
```http
GET /api/employee-stores/employee/{idUser}
```

### 3. Listar Empleados de una Tienda
```http
GET /api/employee-stores/store/{idStore}
```

### 4. Verificar Asignación
```http
GET /api/employee-stores/check?idUser=1&idStore=1
```

### 5. Listar Todas las Relaciones
```http
GET /api/employee-stores
```

### 6. Remover Empleado de Tienda
```http
DELETE /api/employee-stores
Content-Type: application/json

{
    "idUser": 1,
    "idStore": 1
}
```

### 7. Eliminar Relación por ID
```http
DELETE /api/employee-stores/{id}
```

## Respuestas de Ejemplo

### Store Response
```json
{
    "idStore": 1,
    "address": "Av. Principal 123, Lima",
    "status": "Active",
    "createdAt": "2023-11-16T10:00:00",
    "updatedAt": "2023-11-16T10:00:00"
}
```

### Employee-Store Response
```json
{
    "idEmployeeStore": 1,
    "idUser": 1,
    "idStore": 1,
    "createdAt": "2023-11-16T10:00:00",
    "updatedAt": "2023-11-16T10:00:00"
}
```

## Códigos de Estado HTTP

- **200 OK**: Operación exitosa
- **201 Created**: Recurso creado exitosamente
- **400 Bad Request**: Datos inválidos o relación ya existe
- **404 Not Found**: Recurso no encontrado
- **500 Internal Server Error**: Error interno del servidor

## Reglas de Negocio

### Store
1. La dirección es obligatoria y no puede exceder 255 caracteres
2. El estado debe ser 'Active' o 'Inactive'
3. Las tiendas se crean por defecto con estado 'Active'
4. Se pueden buscar tiendas por dirección usando texto parcial

### Employee-Store
1. Un empleado puede estar asignado a múltiples tiendas
2. Una tienda puede tener múltiples empleados
3. No se puede duplicar la relación empleado-tienda
4. Al eliminar un empleado o tienda, se eliminan automáticamente las relaciones

## Base de Datos

### Tabla stores
```sql
- id_store (BIGINT, AUTO_INCREMENT, PRIMARY KEY)
- address (VARCHAR(255), NOT NULL)
- status (VARCHAR(20), NOT NULL, DEFAULT 'Active')
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### Tabla employee_stores
```sql
- id_employee_store (BIGINT, AUTO_INCREMENT, PRIMARY KEY)
- id_user (BIGINT, NOT NULL, FOREIGN KEY)
- id_store (BIGINT, NOT NULL, FOREIGN KEY)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- UNIQUE(id_user, id_store)
```

## Arquitectura

El proyecto sigue Clean Architecture con:

### Capa de Dominio
- `Store.java`: Entidad de dominio con lógica de negocio
- `EmployeeStore.java`: Entidad de dominio para la relación

### Capa de Aplicación
- `StoreService.java`: Lógica de aplicación para stores
- `EmployeeStoreService.java`: Lógica de aplicación para relaciones
- DTOs de request y response

### Capa de Infraestructura
- `StoreJpaEntity.java`: Entidad JPA para persistencia
- `EmployeeStoreJpaEntity.java`: Entidad JPA para relaciones
- `StoreRepository.java`: Repositorio con métodos de consulta
- `EmployeeStoreRepository.java`: Repositorio para relaciones
- `StoreController.java`: API REST endpoints
- `EmployeeStoreController.java`: API REST para relaciones