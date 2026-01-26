package com.example.branchadmin.dto;

import java.time.Instant;

public class RecentUserDTO {
    private final Long id;
    private final String fullName;
    private final Instant registeredAt;

    public RecentUserDTO(Long id, String fullName, Instant registeredAt) {
        this.id = id;
        this.fullName = fullName;
        this.registeredAt = registeredAt;
    }

    public Long getId() {
        return id;
    }

    public String getFullName() {
        return fullName;
    }

    public Instant getRegisteredAt() {
        return registeredAt;
    }
}
