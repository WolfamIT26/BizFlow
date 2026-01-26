package com.example.useradmin.dto;

public class AdminUserSummary {
    private final Long id;
    private final String username;
    private final String fullName;
    private final String email;
    private final String phoneNumber;
    private final String role;
    private final Boolean enabled;

    public AdminUserSummary(Long id, String username, String fullName, String email, String phoneNumber, String role, Boolean enabled) {
        this.id = id;
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.role = role;
        this.enabled = enabled;
    }

    public Long getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getFullName() {
        return fullName;
    }

    public String getEmail() {
        return email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public String getRole() {
        return role;
    }

    public Boolean getEnabled() {
        return enabled;
    }
}
