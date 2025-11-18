package com.mamukas.erp.erpbackend.application.dtos.response;

public class MessageResponseDto {

    private String message;

    // Constructors
    public MessageResponseDto() {}

    public MessageResponseDto(String message) {
        this.message = message;
    }

    // Getters and setters
    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
