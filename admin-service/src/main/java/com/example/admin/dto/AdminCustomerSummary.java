package com.example.admin.dto;

public class AdminCustomerSummary {
    private Long id;
    private String name;
    private String phone;
    private String email;
    private Integer totalPoints;
    private String tier;

    public AdminCustomerSummary() {
    }

    public AdminCustomerSummary(Long id, String name, String phone, String email, Integer totalPoints, String tier) {
        this.id = id;
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.totalPoints = totalPoints;
        this.tier = tier;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public Integer getTotalPoints() { return totalPoints; }
    public void setTotalPoints(Integer totalPoints) { this.totalPoints = totalPoints; }
    public String getTier() { return tier; }
    public void setTier(String tier) { this.tier = tier; }
}
