# Warehouse and Employee-Warehouse API Documentation

## Resumen
Se han creado dos entidades principales:
- **Warehouse**: Gestión de almacenes con dirección y estado
- **Employee_Warehouse**: Relación many-to-many entre empleados y almacenes

## Endpoints de Warehouse

### 1. Crear Almacén
```http
POST /api/warehouses
Content-Type: application/json

{
    "address": "Av. Industrial 123, Lima - Almacén Central",
    "status": "Active"
}
```

### 2. Listar Todos los Almacenes
```http
GET /api/warehouses
```

### 3. Obtener Almacén por ID
```http
GET /api/warehouses/{id}
```

### 4. Listar Almacenes Activos
```http
GET /api/warehouses/active
```

### 5. Listar Almacenes por Estado
```http
GET /api/warehouses/status/{status}
```

### 6. Buscar Almacenes por Dirección
```http
GET /api/warehouses/search?address=Lima
```

### 7. Actualizar Almacén
```http
PUT /api/warehouses/{id}
Content-Type: application/json

{
    "address": "Nueva Dirección Industrial 456",
    "status": "Active"
}
```

### 8. Activar Almacén
```http
PUT /api/warehouses/{id}/activate
```

### 9. Desactivar Almacén
```http
PUT /api/warehouses/{id}/deactivate
```

### 10. Eliminar Almacén
```http
DELETE /api/warehouses/{id}
```

## Endpoints de Employee-Warehouse

### 1. Asignar Empleado a Almacén
```http
POST /api/employee-warehouses
Content-Type: application/json

{
    "idUser": 1,
    "idWarehouse": 1
}
```

### 2. Listar Almacenes de un Empleado
```http
GET /api/employee-warehouses/employee/{idUser}
```

### 3. Listar Empleados de un Almacén
```http
GET /api/employee-warehouses/warehouse/{idWarehouse}
```

### 4. Verificar Asignación
```http
GET /api/employee-warehouses/check?idUser=1&idWarehouse=1
```

### 5. Listar Todas las Relaciones
```http
GET /api/employee-warehouses
```

### 6. Remover Empleado de Almacén
```http
DELETE /api/employee-warehouses
Content-Type: application/json

{
    "idUser": 1,
    "idWarehouse": 1
}
```

### 7. Eliminar Relación por ID
```http
DELETE /api/employee-warehouses/{id}
```

## Respuestas de Ejemplo

### Warehouse Response
```json
{
    "idWarehouse": 1,
    "address": "Av. Industrial 123, Lima - Almacén Central",
    "status": "Active",
    "createdAt": "2023-11-16T10:00:00",
    "updatedAt": "2023-11-16T10:00:00"
}
```

### Employee-Warehouse Response
```json
{
    "idEmployeeWarehouse": 1,
    "idUser": 1,
    "idWarehouse": 1,
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

### Warehouse
1. La dirección es obligatoria y no puede exceder 255 caracteres
2. El estado debe ser 'Active' o 'Inactive'
3. Los almacenes se crean por defecto con estado 'Active'
4. Se pueden buscar almacenes por dirección usando texto parcial

### Employee-Warehouse
1. Un empleado puede estar asignado a múltiples almacenes
2. Un almacén puede tener múltiples empleados
3. No se puede duplicar la relación empleado-almacén
4. Al eliminar un empleado o almacén, se eliminan automáticamente las relaciones

## Base de Datos

### Tabla warehouses
```sql
- id_warehouse (BIGINT, AUTO_INCREMENT, PRIMARY KEY)
- address (VARCHAR(255), NOT NULL)
- status (VARCHAR(20), NOT NULL, DEFAULT 'Active')
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### Tabla employee_warehouses
```sql
- id_employee_warehouse (BIGINT, AUTO_INCREMENT, PRIMARY KEY)
- id_user (BIGINT, NOT NULL, FOREIGN KEY)
- id_warehouse (BIGINT, NOT NULL, FOREIGN KEY)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- UNIQUE(id_user, id_warehouse)
```

## Arquitectura

El proyecto sigue Clean Architecture con:

### Capa de Dominio
- `Warehouse.java`: Entidad de dominio con lógica de negocio
- `EmployeeWarehouse.java`: Entidad de dominio para la relación

### Capa de Aplicación
- `WarehouseService.java`: Lógica de aplicación para warehouses
- `EmployeeWarehouseService.java`: Lógica de aplicación para relaciones
- DTOs de request y response

### Capa de Infraestructura
- `WarehouseJpaEntity.java`: Entidad JPA para persistencia
- `EmployeeWarehouseJpaEntity.java`: Entidad JPA para relaciones
- `WarehouseRepository.java`: Repositorio con métodos de consulta
- `EmployeeWarehouseRepository.java`: Repositorio para relaciones
- `WarehouseController.java`: API REST endpoints
- `EmployeeWarehouseController.java`: API REST para relaciones

## Migración de Store a Warehouse

### Cambios Realizados:
1. **Store** → **Warehouse**
2. **Employee_Store** → **Employee_Warehouse**
3. **id_store** → **id_warehouse**
4. **id_employee_store** → **id_employee_warehouse**
5. Endpoints: `/api/stores` → `/api/warehouses`
6. Endpoints: `/api/employee-stores` → `/api/employee-warehouses`

### Endpoints Actualizados:
- Todas las referencias a "store" han sido cambiadas a "warehouse"
- Los parámetros de URL y JSON han sido actualizados
- Los mensajes de respuesta reflejan la nueva terminología

### Base de Datos:
- Tabla `stores` → `warehouses`
- Tabla `employee_stores` → `employee_warehouses`
- Script de migración disponible en `warehouse_tables.sql`