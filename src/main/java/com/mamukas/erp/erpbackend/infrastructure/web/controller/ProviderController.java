package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.ProviderRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.MessageResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.ProviderResponseDto;
import com.mamukas.erp.erpbackend.application.services.ProviderService;
import com.mamukas.erp.erpbackend.domain.entities.Provider;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/providers")
@CrossOrigin(origins = "*")
public class ProviderController {
    
    @Autowired
    private ProviderService providerService;
    
    @PostMapping
    public ResponseEntity<ProviderResponseDto> createProvider(@Valid @RequestBody ProviderRequestDto request) {
        try {
            Provider provider = providerService.createProvider(
                request.getName(),
                request.getPhone(),
                request.getEmail(),
                request.getNitOrCi()
            );
            ProviderResponseDto response = convertToResponseDto(provider);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @GetMapping
    public ResponseEntity<List<ProviderResponseDto>> getAllProviders() {
        try {
            List<Provider> providers = providerService.findAll();
            List<ProviderResponseDto> response = providers.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ProviderResponseDto> getProviderById(@PathVariable Long id) {
        try {
            Optional<Provider> provider = providerService.findById(id);
            if (provider.isPresent()) {
                ProviderResponseDto response = convertToResponseDto(provider.get());
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/nit/{nitOrCi}")
    public ResponseEntity<ProviderResponseDto> getProviderByNitOrCi(@PathVariable String nitOrCi) {
        try {
            Optional<Provider> provider = providerService.findByNitOrCi(nitOrCi);
            if (provider.isPresent()) {
                ProviderResponseDto response = convertToResponseDto(provider.get());
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/email/{email}")
    public ResponseEntity<ProviderResponseDto> getProviderByEmail(@PathVariable String email) {
        try {
            Optional<Provider> provider = providerService.findByEmail(email);
            if (provider.isPresent()) {
                ProviderResponseDto response = convertToResponseDto(provider.get());
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/search/name")
    public ResponseEntity<List<ProviderResponseDto>> searchProvidersByName(@RequestParam String name) {
        try {
            List<Provider> providers = providerService.findByNameContaining(name);
            List<ProviderResponseDto> response = providers.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/search/phone")
    public ResponseEntity<List<ProviderResponseDto>> searchProvidersByPhone(@RequestParam String phone) {
        try {
            List<Provider> providers = providerService.findByPhoneContaining(phone);
            List<ProviderResponseDto> response = providers.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<ProviderResponseDto>> searchProviders(@RequestParam String term) {
        try {
            List<Provider> providers = providerService.searchProviders(term);
            List<ProviderResponseDto> response = providers.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/with-email")
    public ResponseEntity<List<ProviderResponseDto>> getProvidersWithEmail() {
        try {
            List<Provider> providers = providerService.findProvidersWithEmail();
            List<ProviderResponseDto> response = providers.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/with-phone")
    public ResponseEntity<List<ProviderResponseDto>> getProvidersWithPhone() {
        try {
            List<Provider> providers = providerService.findProvidersWithPhone();
            List<ProviderResponseDto> response = providers.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ProviderResponseDto> updateProvider(@PathVariable Long id, @Valid @RequestBody ProviderRequestDto request) {
        try {
            Provider provider = providerService.updateProvider(
                id,
                request.getName(),
                request.getPhone(),
                request.getEmail(),
                request.getNitOrCi()
            );
            ProviderResponseDto response = convertToResponseDto(provider);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }
    
    @GetMapping("/count")
    public ResponseEntity<Long> countProviders() {
        try {
            long count = providerService.countProviders();
            return new ResponseEntity<>(count, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponseDto> deleteProvider(@PathVariable Long id) {
        try {
            providerService.deleteProvider(id);
            return new ResponseEntity<>(new MessageResponseDto("Provider deleted successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Provider not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    private ProviderResponseDto convertToResponseDto(Provider provider) {
        return new ProviderResponseDto(
            provider.getIdProvider(),
            provider.getName(),
            provider.getPhone(),
            provider.getEmail(),
            provider.getNitOrCi(),
            provider.getCreatedAt(),
            provider.getUpdatedAt()
        );
    }
}
