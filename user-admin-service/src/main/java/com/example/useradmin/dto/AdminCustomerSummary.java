package com.example.useradmin.dto;

public class AdminCustomerSummary {
    private final Long id;
    private final String name;
    private final String phone;
    private final String email;
    private final Integer totalPoints;
    private final String tier;

    public AdminCustomerSummary(Long id, String name, String phone, String email, Integer totalPoints, String tier) {
        this.id = id;
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.totalPoints = totalPoints;
        this.tier = tier;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getPhone() {
        return phone;
    }

    public String getEmail() {
        return email;
    }

    public Integer getTotalPoints() {
        return totalPoints;
    }

    public String getTier() {
        return tier;
    }
}
