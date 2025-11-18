-- Crear tabla stores
CREATE TABLE IF NOT EXISTS stores (
    id_store BIGINT AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_stores_status (status),
    INDEX idx_stores_address (address)
);

-- Crear tabla employee_stores (tabla intermedia)
CREATE TABLE IF NOT EXISTS employee_stores (
    id_employee_store BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_user BIGINT NOT NULL,
    id_store BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    FOREIGN KEY (id_store) REFERENCES stores(id_store) ON DELETE CASCADE,
    UNIQUE KEY unique_employee_store (id_user, id_store),
    INDEX idx_employee_stores_user (id_user),
    INDEX idx_employee_stores_store (id_store)
);

-- Insertar datos de ejemplo para stores
INSERT INTO stores (address, status) VALUES 
('Av. Principal 123, Lima', 'Active'),
('Jr. Comercio 456, Arequipa', 'Active'),
('Calle Real 789, Cusco', 'Inactive')
ON DUPLICATE KEY UPDATE address = VALUES(address);

-- Comentarios sobre el diseño:
-- 1. La tabla stores almacena información básica de las tiendas con dirección y estado
-- 2. El estado puede ser 'Active' o 'Inactive'
-- 3. La tabla employee_stores es una tabla intermedia que relaciona empleados con tiendas
-- 4. Un empleado puede estar asignado a múltiples tiendas
-- 5. Una tienda puede tener múltiples empleados
-- 6. La relación es many-to-many
-- 7. Se incluyen índices para optimizar consultas frecuentes
-- 8. Las foreign keys garantizan integridad referencial
-- 9. La restricción UNIQUE evita duplicados en la relación employee-store