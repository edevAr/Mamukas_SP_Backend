package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.PackRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.MessageResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.PackResponseDto;
import com.mamukas.erp.erpbackend.application.services.PackService;
import com.mamukas.erp.erpbackend.domain.entities.Pack;
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
@RequestMapping("/api/packs")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('USER')")
public class PackController {
    
    @Autowired
    private PackService packService;
    
    @PostMapping
    public ResponseEntity<PackResponseDto> createPack(@Valid @RequestBody PackRequestDto request) {
        try {
            Pack pack = packService.createPack(
                request.getIdProduct(),
                request.getName(),
                request.getExpirationDate(),
                request.getUnits()
            );
            PackResponseDto response = convertToResponseDto(pack);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @GetMapping
    public ResponseEntity<List<PackResponseDto>> getAllPacks() {
        try {
            List<Pack> packs = packService.findAll();
            List<PackResponseDto> response = packs.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<PackResponseDto> getPackById(@PathVariable Long id) {
        try {
            Optional<Pack> pack = packService.findById(id);
            if (pack.isPresent()) {
                PackResponseDto response = convertToResponseDto(pack.get());
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/product/{idProduct}")
    public ResponseEntity<List<PackResponseDto>> getPacksByProduct(@PathVariable Long idProduct) {
        try {
            List<Pack> packs = packService.findByIdProduct(idProduct);
            List<PackResponseDto> response = packs.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/search/name")
    public ResponseEntity<List<PackResponseDto>> searchPacksByName(@RequestParam String name) {
        try {
            List<Pack> packs = packService.findByNameContaining(name);
            List<PackResponseDto> response = packs.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/expiring/soon")
    public ResponseEntity<List<PackResponseDto>> getPacksExpiringSoon() {
        try {
            List<Pack> packs = packService.findExpiringSoon();
            List<PackResponseDto> response = packs.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/stock/available")
    public ResponseEntity<List<PackResponseDto>> getPacksWithStock() {
        try {
            List<Pack> packs = packService.findPacksWithStock();
            List<PackResponseDto> response = packs.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/stock/out")
    public ResponseEntity<List<PackResponseDto>> getPacksOutOfStock() {
        try {
            List<Pack> packs = packService.findPacksOutOfStock();
            List<PackResponseDto> response = packs.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<PackResponseDto> updatePack(@PathVariable Long id, @Valid @RequestBody PackRequestDto request) {
        try {
            Pack pack = packService.updatePack(
                id,
                request.getName(),
                request.getExpirationDate(),
                request.getUnits()
            );
            PackResponseDto response = convertToResponseDto(pack);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }
    
    @PutMapping("/{id}/units/add")
    public ResponseEntity<PackResponseDto> addUnits(@PathVariable Long id, @RequestParam int units) {
        try {
            Pack pack = packService.addUnits(id, units);
            PackResponseDto response = convertToResponseDto(pack);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }
    
    @PutMapping("/{id}/units/remove")
    public ResponseEntity<PackResponseDto> removeUnits(@PathVariable Long id, @RequestParam int units) {
        try {
            Pack pack = packService.removeUnits(id, units);
            PackResponseDto response = convertToResponseDto(pack);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponseDto> deletePack(@PathVariable Long id) {
        try {
            packService.deleteById(id);
            return new ResponseEntity<>(new MessageResponseDto("Pack deleted successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Pack not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    private PackResponseDto convertToResponseDto(Pack pack) {
        return new PackResponseDto(
            pack.getIdPack(),
            pack.getIdProduct(),
            pack.getName(),
            pack.getExpirationDate(),
            pack.getUnits(),
            pack.getCreatedAt(),
            pack.getUpdatedAt()
        );
    }
}
