package com.mamukas.erp.erpbackend.infrastructure.config;

import com.mamukas.erp.erpbackend.application.services.RoleService;
import com.mamukas.erp.erpbackend.application.services.PermissionService;
import com.mamukas.erp.erpbackend.application.services.RolePermissionService;
import com.mamukas.erp.erpbackend.application.services.ProductService;
import com.mamukas.erp.erpbackend.application.services.StoreService;
import com.mamukas.erp.erpbackend.application.services.WarehouseService;
import com.mamukas.erp.erpbackend.application.services.UserService;
import com.mamukas.erp.erpbackend.application.dtos.user.UserRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.role.RoleRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.request.PermissionRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.request.RolePermissionRequestDto;
import com.mamukas.erp.erpbackend.domain.entities.Role;
import com.mamukas.erp.erpbackend.domain.entities.Permission;
import java.math.BigDecimal;
import java.time.LocalDate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * Data initializer that inserts default roles when the application starts
 */
@Component
public class DataInitializer implements ApplicationRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    @Autowired
    private RoleService roleService;

    @Autowired
    private PermissionService permissionService;

    @Autowired
    private RolePermissionService rolePermissionService;

    @Autowired
    private ProductService productService;

    @Autowired
    private StoreService storeService;

    @Autowired
    private WarehouseService warehouseService;

    @Autowired
    private UserService userService;

    @Override
    public void run(ApplicationArguments args) throws Exception {
        logger.info("Starting data initialization...");
        initializeDefaultRoles();
        initializeDefaultPermissions();
        initializeCustomerRolePermissions();
        initializeAdminRolePermissions();
        initializeDefaultAdminUser();
        initializeDefaultProducts();
        initializeDefaultStores();
        initializeDefaultWarehouses();
        logger.info("Data initialization completed.");
    }

    /**
     * Initialize default roles in the system
     */
    private void initializeDefaultRoles() {
        try {
            // Define default roles
            String[] defaultRoles = {"Admin", "StorageManager", "WarehouseManager", "Employee", "Customer"};

            for (String roleName : defaultRoles) {
                // Check if role already exists
                if (!roleService.existsByRoleName(roleName)) {
                    RoleRequestDto roleRequest = new RoleRequestDto();
                    roleRequest.setRoleName(roleName);
                    
                    roleService.createRole(roleRequest);
                    logger.info("Created default role: {}", roleName);
                } else {
                    logger.info("Role already exists: {}", roleName);
                }
            }
            
            logger.info("Default roles initialization completed successfully");
            
        } catch (Exception e) {
            logger.error("Error initializing default roles: {}", e.getMessage(), e);
            // Don't stop the application if role initialization fails
        }
    }

    /**
     * Initialize default permissions in the system
     */
    private void initializeDefaultPermissions() {
        try {
            // Define default permissions (authorities que usan los controladores)
            String[] defaultPermissions = {
                // Inventory Management
                "INVENTORY_CREATE",
                "INVENTORY_READ", 
                "INVENTORY_UPDATE",
                "INVENTORY_DELETE",
                "INVENTORY_*",
                
                // User Management
                "USER_MANAGEMENT_CREATE",
                "USER_MANAGEMENT_READ",
                "USER_MANAGEMENT_UPDATE", 
                "USER_MANAGEMENT_DELETE",
                "USER_*",

                // Products Management
                "CREATE_PRODUCTS",
                "READ_PRODUCTS",
                "UPDATE_PRODUCTS",
                "DELETE_PRODUCTS",
                "PRODUCTS_*",

                // Stores Management
                "CREATE_STORES",
                "READ_STORES",
                "UPDATE_STORES",
                "DELETE_STORES",
                "STORES_*",

                // Warehouses Management
                "CREATE_WAREHOUSES",
                "READ_WAREHOUSES",
                "UPDATE_WAREHOUSES",
                "DELETE_WAREHOUSES",
                "WAREHOUSES_*",

                // Sales Management
                "CREATE_SALE",
                "READ_SALE",
                "UPDATE_SALE",
                "DELETE_SALE",
                "SALES_*",


                // Botton bar buttons
                "READ_PRODUCTS_BUTTON", 
                "READ_STORES_BUTTON", 
                "SHOW_NEW_STORES_BUTTON", 
                "SHOW_PROFILE_BUTTON", 
            };

            for (String permissionName : defaultPermissions) {
                // Check if permission already exists
                if (!permissionService.existsByName(permissionName)) {
                    PermissionRequestDto permissionRequest = new PermissionRequestDto();
                    permissionRequest.setName(permissionName);
                    permissionRequest.setStatus(true); // Active by default
                    
                    permissionService.createPermission(permissionRequest);
                    logger.info("Created default permission: {}", permissionName);
                } else {
                    logger.info("Permission already exists: {}", permissionName);
                }
            }
            
            logger.info("Default permissions initialization completed successfully");
            
        } catch (Exception e) {
            logger.error("Error initializing default permissions: {}", e.getMessage(), e);
            // Don't stop the application if permission initialization fails
        }
    }

    /**
     * Initialize Customer role permissions
     */
    private void initializeCustomerRolePermissions() {
        try {
            // Get Customer role
            Role customerRole = roleService.findByRoleName("Customer").orElse(null);
            if (customerRole == null) {
                logger.warn("Customer role not found, skipping role-permission initialization");
                return;
            }

            // Define permissions to assign to Customer role
            String[] customerPermissions = {
                "READ_PRODUCTS",
                "READ_STORES",
                "READ_PRODUCTS_BUTTON", 
                "READ_STORES_BUTTON", 
                "SHOW_NEW_STORES_BUTTON", 
                "SHOW_PROFILE_BUTTON", 
            };

            for (String permissionName : customerPermissions) {
                try {
                    // Get permission
                    Permission permission = permissionService.findByName(permissionName).orElse(null);
                    if (permission == null) {
                        logger.warn("Permission '{}' not found, skipping assignment to Customer role", permissionName);
                        continue;
                    }

                    // Check if assignment already exists
                    if (!rolePermissionService.isPermissionAssignedToRole(customerRole.getIdRole(), permission.getIdPermission())) {
                        // Create role-permission assignment
                        RolePermissionRequestDto requestDto = new RolePermissionRequestDto();
                        requestDto.setIdRole(customerRole.getIdRole());
                        requestDto.setIdPermission(permission.getIdPermission());
                        
                        rolePermissionService.assignPermissionToRole(requestDto);
                        logger.info("Assigned permission '{}' to Customer role", permissionName);
                    } else {
                        logger.info("Permission '{}' already assigned to Customer role", permissionName);
                    }
                } catch (Exception e) {
                    logger.error("Error assigning permission '{}' to Customer role: {}", permissionName, e.getMessage());
                }
            }
            
            logger.info("Customer role permissions initialization completed successfully");
            
        } catch (Exception e) {
            logger.error("Error initializing Customer role permissions: {}", e.getMessage(), e);
            // Don't stop the application if role-permission initialization fails
        }
    }

    /**
     * Initialize Admin role permissions
     */
    private void initializeAdminRolePermissions() {
        try {
            // Get Admin role
            Role adminRole = roleService.findByRoleName("ADMIN").orElse(null);
            if (adminRole == null) {
                logger.warn("Admin role not found, skipping admin role-permission initialization");
                return;
            }

            // Define permissions to assign to Admin role (all permissions)
            String[] adminPermissions = {
                "INVENTORY_CREATE",
                "INVENTORY_READ", 
                "INVENTORY_UPDATE",
                "INVENTORY_DELETE",
                "USER_MANAGEMENT_CREATE",
                "USER_MANAGEMENT_READ",
                "USER_MANAGEMENT_UPDATE", 
                "USER_MANAGEMENT_DELETE",
                "READ_PRODUCTS_BUTTON", 
                "READ_STORES_BUTTON", 
                "SHOW_NEW_STORES_BUTTON", 
                "SHOW_PROFILE_BUTTON",
                "INVENTORY_*",
                "USER_*",
                "PRODUCTS_*",
                "STORES_*",
                "WAREHOUSES_*",
                "SALES_*"
            };

            for (String permissionName : adminPermissions) {
                try {
                    // Get permission
                    Permission permission = permissionService.findByName(permissionName).orElse(null);
                    if (permission == null) {
                        logger.warn("Permission '{}' not found, skipping assignment to Admin role", permissionName);
                        continue;
                    }

                    // Check if assignment already exists
                    if (!rolePermissionService.isPermissionAssignedToRole(adminRole.getIdRole(), permission.getIdPermission())) {
                        // Create role-permission assignment
                        RolePermissionRequestDto requestDto = new RolePermissionRequestDto();
                        requestDto.setIdRole(adminRole.getIdRole());
                        requestDto.setIdPermission(permission.getIdPermission());
                        
                        rolePermissionService.assignPermissionToRole(requestDto);
                        logger.info("Assigned permission '{}' to Admin role", permissionName);
                    } else {
                        logger.info("Permission '{}' already assigned to Admin role", permissionName);
                    }
                } catch (Exception e) {
                    logger.error("Error assigning permission '{}' to Admin role: {}", permissionName, e.getMessage());
                }
            }
            
            logger.info("Admin role permissions initialization completed successfully");
            
        } catch (Exception e) {
            logger.error("Error initializing Admin role permissions: {}", e.getMessage(), e);
            // Don't stop the application if role-permission initialization fails
        }
    }

    /**
     * Initialize default admin user
     */
    private void initializeDefaultAdminUser() {
        try {
            logger.info("Initializing default admin user...");

            // Check if admin user already exists
            String adminUsername = "admin";
            String adminEmail = "admin@mamukas.com";
            
            if (userService.existsByUsername(adminUsername) || userService.existsByEmail(adminEmail)) {
                logger.info("Admin user already exists, skipping creation");
                return;
            }

            // Create admin user
            UserRequestDto adminUser = new UserRequestDto();
            adminUser.setUsername(adminUsername);
            adminUser.setEmail(adminEmail);
            adminUser.setPassword("admin123"); // Default password - should be changed in production
            adminUser.setName("Administrator");
            adminUser.setLastName("System");
            adminUser.setAge(30);
            adminUser.setCi("00000000");
            adminUser.setStatus(1); // Active
            adminUser.setRoleName("Admin");

            userService.createUser(adminUser);
            logger.info("Default admin user created successfully - Username: '{}', Password: 'admin123'", adminUsername);
            logger.warn("SECURITY WARNING: Default admin user created with password 'admin123'. Please change it in production!");

        } catch (Exception e) {
            logger.error("Error creating default admin user: {}", e.getMessage(), e);
            // Don't stop the application if admin user creation fails
        }
    }

    /**
     * Initialize 25 default products with test data
     */
    private void initializeDefaultProducts() {
        try {
            logger.info("Initializing default products...");

            // Array of product data: {name, status, price, expirationDate}
            Object[][] products = {
                {"Laptop HP Pavilion", "Active", new BigDecimal("899.99"), LocalDate.of(2025, 12, 31)},
                {"Mouse Logitech MX Master", "Active", new BigDecimal("99.99"), LocalDate.of(2026, 6, 30)},
                {"Teclado Mecánico RGB", "Active", new BigDecimal("149.99"), LocalDate.of(2026, 12, 31)},
                {"Monitor Samsung 24\"", "Active", new BigDecimal("199.99"), LocalDate.of(2027, 3, 31)},
                {"Auriculares Sony WH-1000XM4", "Active", new BigDecimal("299.99"), LocalDate.of(2026, 9, 30)},
                {"Smartphone iPhone 14", "Active", new BigDecimal("799.99"), LocalDate.of(2025, 12, 31)},
                {"Tablet iPad Air", "Active", new BigDecimal("599.99"), LocalDate.of(2026, 6, 30)},
                {"Cámara Canon EOS R6", "Active", new BigDecimal("2499.99"), LocalDate.of(2027, 12, 31)},
                {"Impresora HP LaserJet", "Active", new BigDecimal("349.99"), LocalDate.of(2028, 3, 31)},
                {"Disco Duro Externo 2TB", "Active", new BigDecimal("89.99"), LocalDate.of(2026, 12, 31)},
                {"Webcam Logitech C920", "Active", new BigDecimal("79.99"), LocalDate.of(2026, 9, 30)},
                {"Router Wi-Fi 6", "Active", new BigDecimal("159.99"), LocalDate.of(2027, 6, 30)},
                {"Altavoces Bluetooth JBL", "Active", new BigDecimal("179.99"), LocalDate.of(2026, 12, 31)},
                {"SSD Samsung 1TB", "Active", new BigDecimal("129.99"), LocalDate.of(2028, 6, 30)},
                {"Tarjeta Gráfica RTX 4060", "Active", new BigDecimal("399.99"), LocalDate.of(2026, 3, 31)},
                {"Procesador AMD Ryzen 7", "Active", new BigDecimal("299.99"), LocalDate.of(2027, 12, 31)},
                {"Memoria RAM 32GB", "Active", new BigDecimal("189.99"), LocalDate.of(2028, 6, 30)},
                {"Fuente de Poder 750W", "Active", new BigDecimal("119.99"), LocalDate.of(2027, 9, 30)},
                {"Case Gaming RGB", "Active", new BigDecimal("89.99"), LocalDate.of(2026, 12, 31)},
                {"Cooler CPU Líquido", "Active", new BigDecimal("149.99"), LocalDate.of(2027, 3, 31)},
                {"Switch Ethernet 24 puertos", "Active", new BigDecimal("299.99"), LocalDate.of(2028, 12, 31)},
                {"UPS 1500VA", "Active", new BigDecimal("199.99"), LocalDate.of(2027, 6, 30)},
                {"Servidor Rack 1U", "Active", new BigDecimal("1999.99"), LocalDate.of(2029, 12, 31)},
                {"Cable HDMI 4K", "Active", new BigDecimal("24.99"), LocalDate.of(2026, 6, 30)},
                {"Hub USB-C 7 en 1", "Active", new BigDecimal("49.99"), LocalDate.of(2026, 9, 30)}
            };

            // Create products
            for (Object[] productData : products) {
                try {
                    String name = (String) productData[0];
                    String status = (String) productData[1];
                    BigDecimal price = (BigDecimal) productData[2];
                    LocalDate expirationDate = (LocalDate) productData[3];

                    productService.createProduct(name, status, price, expirationDate);
                    logger.info("Created product: {}", name);
                } catch (Exception e) {
                    logger.error("Error creating product '{}': {}", productData[0], e.getMessage());
                }
            }

            logger.info("Default products initialization completed successfully");

        } catch (Exception e) {
            logger.error("Error initializing default products: {}", e.getMessage(), e);
            // Don't stop the application if product initialization fails
        }
    }

    /**
     * Initialize 8 default stores with test data
     */
    private void initializeDefaultStores() {
        try {
            logger.info("Initializing default stores...");

            // Array of store data: {name, address, businessHours, idCompany}
            Object[][] stores = {
                {"TechStore Centro", "Av. Principal 123, Centro Histórico", "Lunes a Viernes: 8:00 AM - 8:00 PM, Sábados: 9:00 AM - 6:00 PM", 1L},
                {"TechStore Norte", "Blvd. Norte 456, Zona Residencial Norte", "Lunes a Sábado: 9:00 AM - 9:00 PM, Domingos: 10:00 AM - 6:00 PM", 1L},
                {"TechStore Sur", "Av. Sur 789, Plaza Comercial del Sur", "Lunes a Domingo: 10:00 AM - 10:00 PM", 1L},
                {"TechStore Este", "Calle Este 321, Centro Comercial Oriente", "Lunes a Viernes: 9:00 AM - 9:00 PM, Fines de semana: 10:00 AM - 8:00 PM", 1L},
                {"TechStore Oeste", "Av. Poniente 654, Mall del Oeste", "Todos los días: 10:00 AM - 9:00 PM", 1L},
                {"TechStore Express", "Aeropuerto Internacional, Terminal A", "24 horas, todos los días", 1L},
                {"TechStore Universitaria", "Av. Universidad 987, Ciudad Universitaria", "Lunes a Viernes: 8:00 AM - 7:00 PM, Sábados: 9:00 AM - 5:00 PM", 1L},
                {"TechStore Outlet", "Zona Industrial 147, Parque Industrial", "Lunes a Sábado: 9:00 AM - 6:00 PM", 1L}
            };

            // Create stores
            for (Object[] storeData : stores) {
                try {
                    String name = (String) storeData[0];
                    String address = (String) storeData[1];
                    String businessHours = (String) storeData[2];
                    Long idCompany = (Long) storeData[3];

                    storeService.createStore(name, address, businessHours, idCompany);
                    logger.info("Created store: {}", name);
                } catch (Exception e) {
                    logger.error("Error creating store '{}': {}", storeData[0], e.getMessage());
                }
            }

            logger.info("Default stores initialization completed successfully");

        } catch (Exception e) {
            logger.error("Error initializing default stores: {}", e.getMessage(), e);
            // Don't stop the application if store initialization fails
        }
    }

    /**
     * Initialize 10 default warehouses with test data
     */
    private void initializeDefaultWarehouses() {
        try {
            logger.info("Initializing default warehouses...");

            // Array of warehouse addresses
            String[] warehouseAddresses = {
                "Parque Industrial Norte, Nave A-1, Km 15 Carretera Industrial",
                "Zona Logística Sur, Bodega Central B-23, Av. Distribución 456",
                "Complejo Logístico Este, Módulo C-7, Blvd. Comercial 789",
                "Centro de Distribución Oeste, Almacén D-12, Calle Logística 321",
                "Hub Metropolitano, Facility E-5, Anillo Periférico Norte 654",
                "Terminal de Carga Aérea, Hangar F-18, Zona Aeroportuaria 987",
                "Puerto Seco Intermodal, Patio G-9, Vía Férrea Industrial 147",
                "Centro Logístico Refrigerado, Cámara H-4, Zona Fría 258",
                "Almacén de Productos Peligrosos, Instalación I-11, Área Especial 369",
                "Depósito de Alta Rotación, Plataforma J-6, Corredor Express 159"
            };

            // Create warehouses
            for (String address : warehouseAddresses) {
                try {
                    warehouseService.createWarehouse(address);
                    logger.info("Created warehouse at: {}", address.substring(0, Math.min(50, address.length())) + "...");
                } catch (Exception e) {
                    logger.error("Error creating warehouse at '{}': {}", address.substring(0, Math.min(30, address.length())) + "...", e.getMessage());
                }
            }

            logger.info("Default warehouses initialization completed successfully");

        } catch (Exception e) {
            logger.error("Error initializing default warehouses: {}", e.getMessage(), e);
            // Don't stop the application if warehouse initialization fails
        }
    }
}
