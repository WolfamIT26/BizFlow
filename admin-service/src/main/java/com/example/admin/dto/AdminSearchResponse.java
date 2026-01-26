package com.example.admin.dto;

import java.util.List;

public class AdminSearchResponse {
    private List<AdminUserSummary> users;
    private List<AdminCustomerSummary> customers;
    private int totalUsers;
    private int totalCustomers;

    public AdminSearchResponse() {
    }

    public AdminSearchResponse(List<AdminUserSummary> users,
                               List<AdminCustomerSummary> customers,
                               int totalUsers,
                               int totalCustomers) {
        this.users = users;
        this.customers = customers;
        this.totalUsers = totalUsers;
        this.totalCustomers = totalCustomers;
    }

    public List<AdminUserSummary> getUsers() { return users; }
    public void setUsers(List<AdminUserSummary> users) { this.users = users; }
    public List<AdminCustomerSummary> getCustomers() { return customers; }
    public void setCustomers(List<AdminCustomerSummary> customers) { this.customers = customers; }
    public int getTotalUsers() { return totalUsers; }
    public void setTotalUsers(int totalUsers) { this.totalUsers = totalUsers; }
    public int getTotalCustomers() { return totalCustomers; }
    public void setTotalCustomers(int totalCustomers) { this.totalCustomers = totalCustomers; }
}
