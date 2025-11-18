package com.mamukas.erp.erpbackend.infrastructure.web.controller;

import com.mamukas.erp.erpbackend.application.dtos.request.BoxRequestDto;
import com.mamukas.erp.erpbackend.application.dtos.response.MessageResponseDto;
import com.mamukas.erp.erpbackend.application.dtos.response.BoxResponseDto;
import com.mamukas.erp.erpbackend.application.services.BoxService;
import com.mamukas.erp.erpbackend.domain.entities.Box;
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
@RequestMapping("/api/boxes")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('USER')")
public class BoxController {
    
    @Autowired
    private BoxService boxService;
    
    @PostMapping
    public ResponseEntity<BoxResponseDto> createBox(@Valid @RequestBody BoxRequestDto request) {
        try {
            Box box = boxService.createBox(
                request.getIdProduct(),
                request.getName(),
                request.getExpirationDate(),
                request.getUnits()
            );
            BoxResponseDto response = convertToResponseDto(box);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @GetMapping
    public ResponseEntity<List<BoxResponseDto>> getAllBoxes() {
        try {
            List<Box> boxes = boxService.findAll();
            List<BoxResponseDto> response = boxes.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<BoxResponseDto> getBoxById(@PathVariable Long id) {
        try {
            Optional<Box> box = boxService.findById(id);
            if (box.isPresent()) {
                BoxResponseDto response = convertToResponseDto(box.get());
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/product/{idProduct}")
    public ResponseEntity<List<BoxResponseDto>> getBoxesByProduct(@PathVariable Long idProduct) {
        try {
            List<Box> boxes = boxService.findByIdProduct(idProduct);
            List<BoxResponseDto> response = boxes.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/search/name")
    public ResponseEntity<List<BoxResponseDto>> searchBoxesByName(@RequestParam String name) {
        try {
            List<Box> boxes = boxService.findByNameContaining(name);
            List<BoxResponseDto> response = boxes.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/expiring/soon")
    public ResponseEntity<List<BoxResponseDto>> getBoxesExpiringSoon() {
        try {
            List<Box> boxes = boxService.findExpiringSoon();
            List<BoxResponseDto> response = boxes.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/stock/available")
    public ResponseEntity<List<BoxResponseDto>> getBoxesWithStock() {
        try {
            List<Box> boxes = boxService.findBoxesWithStock();
            List<BoxResponseDto> response = boxes.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping("/stock/out")
    public ResponseEntity<List<BoxResponseDto>> getBoxesOutOfStock() {
        try {
            List<Box> boxes = boxService.findBoxesOutOfStock();
            List<BoxResponseDto> response = boxes.stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<BoxResponseDto> updateBox(@PathVariable Long id, @Valid @RequestBody BoxRequestDto request) {
        try {
            Box box = boxService.updateBox(
                id,
                request.getName(),
                request.getExpirationDate(),
                request.getUnits()
            );
            BoxResponseDto response = convertToResponseDto(box);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }
    
    @PutMapping("/{id}/units/add")
    public ResponseEntity<BoxResponseDto> addUnits(@PathVariable Long id, @RequestParam int units) {
        try {
            Box box = boxService.addUnits(id, units);
            BoxResponseDto response = convertToResponseDto(box);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }
    
    @PutMapping("/{id}/units/remove")
    public ResponseEntity<BoxResponseDto> removeUnits(@PathVariable Long id, @RequestParam int units) {
        try {
            Box box = boxService.removeUnits(id, units);
            BoxResponseDto response = convertToResponseDto(box);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponseDto> deleteBox(@PathVariable Long id) {
        try {
            boxService.deleteById(id);
            return new ResponseEntity<>(new MessageResponseDto("Box deleted successfully"), HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(new MessageResponseDto("Box not found"), HttpStatus.NOT_FOUND);
        }
    }
    
    private BoxResponseDto convertToResponseDto(Box box) {
        return new BoxResponseDto(
            box.getIdBox(),
            box.getIdProduct(),
            box.getName(),
            box.getExpirationDate(),
            box.getUnits(),
            box.getCreatedAt(),
            box.getUpdatedAt()
        );
    }
}
