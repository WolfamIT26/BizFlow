package com.example.useradmin.dto;

public class AdminUserStatsResponse {
    private final int activeUsers;
    private final int newRegistrations;
    private final int windowDays;

    public AdminUserStatsResponse(int activeUsers, int newRegistrations, int windowDays) {
        this.activeUsers = activeUsers;
        this.newRegistrations = newRegistrations;
        this.windowDays = windowDays;
    }

    public int getActiveUsers() {
        return activeUsers;
    }

    public int getNewRegistrations() {
        return newRegistrations;
    }

    public int getWindowDays() {
        return windowDays;
    }
}
