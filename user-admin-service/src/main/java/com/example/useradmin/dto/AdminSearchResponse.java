package com.example.useradmin.dto;

import java.util.List;

public class AdminSearchResponse {
    private final List<AdminUserSummary> users;
    private final List<AdminCustomerSummary> customers;
    private final int userCount;
    private final int customerCount;

    public AdminSearchResponse(List<AdminUserSummary> users,
                               List<AdminCustomerSummary> customers,
                               int userCount,
                               int customerCount) {
        this.users = users;
        this.customers = customers;
        this.userCount = userCount;
        this.customerCount = customerCount;
    }

    public List<AdminUserSummary> getUsers() {
        return users;
    }

    public List<AdminCustomerSummary> getCustomers() {
        return customers;
    }

    public int getUserCount() {
        return userCount;
    }

    public int getCustomerCount() {
        return customerCount;
    }
}
