package com.mamukas.erp.erpbackend.application.exception;

/**
 * Exception thrown when a user with status 2 (inactive) tries to login
 */
public class AccountInactiveException extends RuntimeException {
    public AccountInactiveException(String message) {
        super(message);
    }
}
