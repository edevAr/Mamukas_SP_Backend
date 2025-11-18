package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.EmployeeStoreRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.EmployeeStoreResponseDto;
import com.mamukas.erp.erpbackend.application.services.EmployeeStoreService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/employee-stores")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('USER')")
public class EmployeeStoreController {

    @Autowired
    private EmployeeStoreService employeeStoreService;

    /**
     * Assign employee to store
     */
    @PostMapping
    public ResponseEntity<EmployeeStoreResponseDto> assignEmployeeToStore(@Valid @RequestBody EmployeeStoreRequestDto request) {
        try {
            EmployeeStoreResponseDto response = employeeStoreService.assignEmployeeToStore(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get all employee-store assignments
     */
    @GetMapping
    public ResponseEntity<List<EmployeeStoreResponseDto>> getAllEmployeeStores() {
        try {
            List<EmployeeStoreResponseDto> assignments = employeeStoreService.getAllEmployeeStores();
            return ResponseEntity.ok(assignments);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get employee-store assignment by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<EmployeeStoreResponseDto> getEmployeeStoreById(@PathVariable Long id) {
        try {
            EmployeeStoreResponseDto assignment = employeeStoreService.getEmployeeStoreById(id);
            return ResponseEntity.ok(assignment);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get all stores for an employee
     */
    @GetMapping("/employee/{idEmployee}")
    public ResponseEntity<List<EmployeeStoreResponseDto>> getStoresByEmployee(@PathVariable Long idEmployee) {
        try {
            List<EmployeeStoreResponseDto> stores = employeeStoreService.getStoresByEmployee(idEmployee);
            return ResponseEntity.ok(stores);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get all employees for a store
     */
    @GetMapping("/store/{idStore}")
    public ResponseEntity<List<EmployeeStoreResponseDto>> getEmployeesByStore(@PathVariable Long idStore) {
        try {
            List<EmployeeStoreResponseDto> employees = employeeStoreService.getEmployeesByStore(idStore);
            return ResponseEntity.ok(employees);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Check if employee is assigned to store
     */
    @GetMapping("/check")
    public ResponseEntity<Boolean> isEmployeeAssignedToStore(@RequestParam Long idEmployee, @RequestParam Long idStore) {
        try {
            boolean isAssigned = employeeStoreService.isEmployeeAssignedToStore(idEmployee, idStore);
            return ResponseEntity.ok(isAssigned);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Remove employee from store
     */
    @DeleteMapping
    public ResponseEntity<String> removeEmployeeFromStore(@RequestParam Long idEmployee, @RequestParam Long idStore) {
        try {
            boolean removed = employeeStoreService.removeEmployeeFromStore(idEmployee, idStore);
            if (removed) {
                return ResponseEntity.ok("Empleado removido de la tienda exitosamente");
            } else {
                return ResponseEntity.badRequest().body("Error al remover empleado de la tienda");
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno del servidor");
        }
    }

    /**
     * Remove assignment by ID
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<String> removeEmployeeStore(@PathVariable Long id) {
        try {
            boolean removed = employeeStoreService.removeEmployeeStore(id);
            if (removed) {
                return ResponseEntity.ok("Asignación eliminada exitosamente");
            } else {
                return ResponseEntity.badRequest().body("Error al eliminar asignación");
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno del servidor");
        }
    }

    /**
     * Remove all stores from employee
     */
    @DeleteMapping("/employee/{idEmployee}")
    public ResponseEntity<String> removeAllStoresFromEmployee(@PathVariable Long idEmployee) {
        try {
            boolean removed = employeeStoreService.removeAllStoresFromEmployee(idEmployee);
            if (removed) {
                return ResponseEntity.ok("Todas las tiendas removidas del empleado exitosamente");
            } else {
                return ResponseEntity.badRequest().body("Error al remover tiendas del empleado");
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno del servidor");
        }
    }

    /**
     * Remove all employees from store
     */
    @DeleteMapping("/store/{idStore}")
    public ResponseEntity<String> removeAllEmployeesFromStore(@PathVariable Long idStore) {
        try {
            boolean removed = employeeStoreService.removeAllEmployeesFromStore(idStore);
            if (removed) {
                return ResponseEntity.ok("Todos los empleados removidos de la tienda exitosamente");
            } else {
                return ResponseEntity.badRequest().body("Error al remover empleados de la tienda");
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno del servidor");
        }
    }

    /**
     * Get assignment count
     */
    @GetMapping("/count")
    public ResponseEntity<Long> getEmployeeStoreCount() {
        try {
            long count = employeeStoreService.getEmployeeStoreCount();
            return ResponseEntity.ok(count);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
