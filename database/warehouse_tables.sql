-- Script SQL actualizado para Warehouse (anteriormente Store)
-- Crear tabla warehouses (anteriormente stores)
CREATE TABLE IF NOT EXISTS warehouses (
    id_warehouse BIGINT AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_warehouses_status (status),
    INDEX idx_warehouses_address (address)
);

-- Crear tabla employee_warehouses (anteriormente employee_stores)
CREATE TABLE IF NOT EXISTS employee_warehouses (
    id_employee_warehouse BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_user BIGINT NOT NULL,
    id_warehouse BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    FOREIGN KEY (id_warehouse) REFERENCES warehouses(id_warehouse) ON DELETE CASCADE,
    UNIQUE KEY unique_employee_warehouse (id_user, id_warehouse),
    INDEX idx_employee_warehouses_user (id_user),
    INDEX idx_employee_warehouses_warehouse (id_warehouse)
);

-- Insertar datos de ejemplo para warehouses
INSERT INTO warehouses (address, status) VALUES 
('Av. Industrial 123, Lima - Almacén Central', 'Active'),
('Jr. Logística 456, Arequipa - Almacén Sur', 'Active'),
('Calle Distribución 789, Cusco - Almacén Regional', 'Inactive'),
('Av. Comercio 321, Trujillo - Almacén Norte', 'Active')
ON DUPLICATE KEY UPDATE address = VALUES(address);

-- Script de migración si ya tienes tablas stores/employee_stores
/*
-- Solo ejecutar si necesitas migrar de stores a warehouses

-- Migrar datos de stores a warehouses
INSERT INTO warehouses (id_warehouse, address, status, created_at, updated_at)
SELECT id_store, address, status, created_at, updated_at 
FROM stores;

-- Migrar datos de employee_stores a employee_warehouses
INSERT INTO employee_warehouses (id_employee_warehouse, id_user, id_warehouse, created_at, updated_at)
SELECT id_employee_store, id_user, id_store, created_at, updated_at 
FROM employee_stores;

-- Eliminar tablas antiguas (CUIDADO: solo si estás seguro)
-- DROP TABLE employee_stores;
-- DROP TABLE stores;
*/

-- Comentarios sobre el diseño actualizado:
-- 1. La tabla warehouses almacena información de almacenes con dirección y estado
-- 2. El estado puede ser 'Active' o 'Inactive'
-- 3. La tabla employee_warehouses es una tabla intermedia que relaciona empleados con almacenes
-- 4. Un empleado puede estar asignado a múltiples almacenes
-- 5. Un almacén puede tener múltiples empleados
-- 6. La relación es many-to-many
-- 7. Se incluyen índices para optimizar consultas frecuentes
-- 8. Las foreign keys garantizan integridad referencial
-- 9. La restricción UNIQUE evita duplicados en la relación employee-warehouse