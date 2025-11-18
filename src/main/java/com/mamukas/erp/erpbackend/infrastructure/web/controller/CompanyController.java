package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.CompanyRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.CompanyResponseDto;
import com.mamukas.erp.erpbackend.application.services.CompanyService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/companies")
@CrossOrigin(origins = "*")
public class CompanyController {

    @Autowired
    private CompanyService companyService;

    /**
     * Create a new company
     */
    @PreAuthorize("hasAuthority('COMPANY_CREATE') or hasRole('ADMIN')")
    @PostMapping
    public ResponseEntity<CompanyResponseDto> createCompany(@Valid @RequestBody CompanyRequestDto request) {
        try {
            CompanyResponseDto response = companyService.createCompany(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get all companies
     */
    @PreAuthorize("hasAuthority('COMPANY_READ') or hasRole('ADMIN')")
    @GetMapping
    public ResponseEntity<List<CompanyResponseDto>> getAllCompanies() {
        try {
            List<CompanyResponseDto> companies = companyService.getAllCompanies();
            return ResponseEntity.ok(companies);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get company by ID
     */
    @PreAuthorize("hasAuthority('COMPANY_READ') or hasRole('ADMIN')")
    @GetMapping("/{id}")
    public ResponseEntity<CompanyResponseDto> getCompanyById(@PathVariable Long id) {
        try {
            CompanyResponseDto company = companyService.getCompanyById(id);
            return ResponseEntity.ok(company);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Update a company
     */
    @PreAuthorize("hasAuthority('COMPANY_UPDATE') or hasRole('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<CompanyResponseDto> updateCompany(@PathVariable Long id, 
                                                           @Valid @RequestBody CompanyRequestDto request) {
        try {
            CompanyResponseDto response = companyService.updateCompany(id, request);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Delete a company
     */
    @PreAuthorize("hasAuthority('COMPANY_DELETE') or hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteCompany(@PathVariable Long id) {
        try {
            boolean deleted = companyService.deleteCompany(id);
            if (deleted) {
                return ResponseEntity.ok("Empresa eliminada exitosamente");
            } else {
                return ResponseEntity.badRequest().body("Error al eliminar empresa");
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno del servidor");
        }
    }

    /**
     * Open company
     */
    @PreAuthorize("hasAuthority('COMPANY_UPDATE') or hasRole('ADMIN')")
    @PutMapping("/{id}/open")
    public ResponseEntity<CompanyResponseDto> openCompany(@PathVariable Long id) {
        try {
            CompanyResponseDto response = companyService.openCompany(id);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Close company
     */
    @PreAuthorize("hasAuthority('COMPANY_UPDATE') or hasRole('ADMIN')")
    @PutMapping("/{id}/close")
    public ResponseEntity<CompanyResponseDto> closeCompany(@PathVariable Long id) {
        try {
            CompanyResponseDto response = companyService.closeCompany(id);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get companies by status
     */
    @PreAuthorize("hasAuthority('COMPANY_READ') or hasRole('ADMIN')")
    @GetMapping("/status/{status}")
    public ResponseEntity<List<CompanyResponseDto>> getCompaniesByStatus(@PathVariable String status) {
        try {
            List<CompanyResponseDto> companies = companyService.getCompaniesByStatus(status);
            return ResponseEntity.ok(companies);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get opened companies
     */
    @PreAuthorize("hasAuthority('COMPANY_READ') or hasRole('ADMIN')")
    @GetMapping("/opened")
    public ResponseEntity<List<CompanyResponseDto>> getOpenedCompanies() {
        try {
            List<CompanyResponseDto> companies = companyService.getOpenedCompanies();
            return ResponseEntity.ok(companies);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get closed companies
     */
    @PreAuthorize("hasAuthority('COMPANY_READ') or hasRole('ADMIN')")
    @GetMapping("/closed")
    public ResponseEntity<List<CompanyResponseDto>> getClosedCompanies() {
        try {
            List<CompanyResponseDto> companies = companyService.getClosedCompanies();
            return ResponseEntity.ok(companies);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Search companies by name
     */
    @PreAuthorize("hasAuthority('COMPANY_READ') or hasRole('ADMIN')")
    @GetMapping("/search/name")
    public ResponseEntity<List<CompanyResponseDto>> searchCompaniesByName(@RequestParam String name) {
        try {
            List<CompanyResponseDto> companies = companyService.searchCompaniesByName(name);
            return ResponseEntity.ok(companies);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Search companies by address
     */
    @PreAuthorize("hasAuthority('COMPANY_READ') or hasRole('ADMIN')")
    @GetMapping("/search/address")
    public ResponseEntity<List<CompanyResponseDto>> searchCompaniesByAddress(@RequestParam String address) {
        try {
            List<CompanyResponseDto> companies = companyService.searchCompaniesByAddress(address);
            return ResponseEntity.ok(companies);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Search companies by name and status
     */
    @PreAuthorize("hasAuthority('COMPANY_READ') or hasRole('ADMIN')")
    @GetMapping("/search/name-status")
    public ResponseEntity<List<CompanyResponseDto>> searchCompaniesByNameAndStatus(
            @RequestParam String name, @RequestParam String status) {
        try {
            List<CompanyResponseDto> companies = companyService.searchCompaniesByNameAndStatus(name, status);
            return ResponseEntity.ok(companies);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Search companies by address and status
     */
    @PreAuthorize("hasAuthority('COMPANY_READ') or hasRole('ADMIN')")
    @GetMapping("/search/address-status")
    public ResponseEntity<List<CompanyResponseDto>> searchCompaniesByAddressAndStatus(
            @RequestParam String address, @RequestParam String status) {
        try {
            List<CompanyResponseDto> companies = companyService.searchCompaniesByAddressAndStatus(address, status);
            return ResponseEntity.ok(companies);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get company count
     */
    @PreAuthorize("hasAuthority('COMPANY_READ') or hasRole('ADMIN')")
    @GetMapping("/count")
    public ResponseEntity<Long> getCompanyCount() {
        try {
            long count = companyService.getCompanyCount();
            return ResponseEntity.ok(count);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
