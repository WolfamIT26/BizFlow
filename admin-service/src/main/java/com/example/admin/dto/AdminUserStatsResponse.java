package com.example.admin.dto;

public class AdminUserStatsResponse {
    private int activeUsers;
    private int newRegistrations;
    private int windowDays;

    public AdminUserStatsResponse() {
    }

    public AdminUserStatsResponse(int activeUsers, int newRegistrations, int windowDays) {
        this.activeUsers = activeUsers;
        this.newRegistrations = newRegistrations;
        this.windowDays = windowDays;
    }

    public int getActiveUsers() {
        return activeUsers;
    }

    public void setActiveUsers(int activeUsers) {
        this.activeUsers = activeUsers;
    }

    public int getNewRegistrations() {
        return newRegistrations;
    }

    public void setNewRegistrations(int newRegistrations) {
        this.newRegistrations = newRegistrations;
    }

    public int getWindowDays() {
        return windowDays;
    }

    public void setWindowDays(int windowDays) {
        this.windowDays = windowDays;
    }
}
