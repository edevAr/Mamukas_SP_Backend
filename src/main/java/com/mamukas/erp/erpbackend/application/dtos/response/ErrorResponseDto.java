package com.mamukas.erp.erpbackend.application.dtos.response;

/**
 * Standard error response DTO for API errors
 */
public class ErrorResponseDto {
    private String error;
    private String message;
    
    public ErrorResponseDto() {}
    
    public ErrorResponseDto(String error, String message) {
        this.error = error;
        this.message = message;
    }
    
    // Getters and setters
    public String getError() {
        return error;
    }
    
    public void setError(String error) {
        this.error = error;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
}
