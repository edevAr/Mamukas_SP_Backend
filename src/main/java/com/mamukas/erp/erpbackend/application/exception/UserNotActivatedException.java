package com.mamukas.erp.erpbackend.application.exception;

/**
 * Exception thrown when a user with status 0 (pending activation) tries to login
 */
public class UserNotActivatedException extends RuntimeException {
    public UserNotActivatedException(String message) {
        super(message);
    }
}
