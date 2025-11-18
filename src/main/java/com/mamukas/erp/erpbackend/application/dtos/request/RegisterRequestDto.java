package com.mamukas.erp.erpbackend.application.dtos.request;

import jakarta.validation.constraints.*;

public class RegisterRequestDto {

    @NotBlank(message = "El nombre de usuario no puede estar vacío")
    @Size(min = 3, max = 50, message = "El nombre de usuario debe tener entre 3 y 50 caracteres")
    private String username;

    @NotBlank(message = "El email no puede estar vacío")
    @Email(message = "Debe ser un email válido")
    @Size(max = 100, message = "El email no puede exceder 100 caracteres")
    private String email;

    @NotBlank(message = "La contraseña no puede estar vacía")
    @Size(min = 6, max = 100, message = "La contraseña debe tener entre 6 y 100 caracteres")
    private String password;

    @NotBlank(message = "La confirmación de contraseña no puede estar vacía")
    private String confirmPassword;

    @NotBlank(message = "El nombre no puede estar vacío")
    @Size(max = 50, message = "El nombre no puede exceder 50 caracteres")
    private String name;

    @NotBlank(message = "El apellido no puede estar vacío")
    @Size(max = 50, message = "El apellido no puede exceder 50 caracteres")
    private String lastName;

    @NotNull(message = "La edad es obligatoria")
    @Min(value = 18, message = "Debe ser mayor de edad (18 años)")
    @Max(value = 120, message = "La edad no puede ser mayor a 120 años")
    private Integer age;

    @NotBlank(message = "La cédula de identidad no puede estar vacía")
    @Size(max = 15, message = "La cédula no puede exceder 15 caracteres")
    private String ci;

    // Constructors
    public RegisterRequestDto() {}

    public RegisterRequestDto(String username, String email, String password, String confirmPassword,
                             String name, String lastName, Integer age, String ci) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.confirmPassword = confirmPassword;
        this.name = name;
        this.lastName = lastName;
        this.age = age;
        this.ci = ci;
    }

    // Getters and setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getConfirmPassword() {
        return confirmPassword;
    }

    public void setConfirmPassword(String confirmPassword) {
        this.confirmPassword = confirmPassword;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getCi() {
        return ci;
    }

    public void setCi(String ci) {
        this.ci = ci;
    }
}
