package com.example.bizflow.service;

import com.example.bizflow.dto.AdminDashboardSummary;
import com.example.bizflow.dto.BranchSummary;
import com.example.bizflow.dto.OwnerDashboardSummary;
import com.example.bizflow.dto.RecentUserSummary;
import com.example.bizflow.integration.AuthClient;
import com.example.bizflow.integration.CatalogClient;
import com.example.bizflow.integration.CustomerClient;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class DashboardService {
    private final AuthClient authClient;
    private final CustomerClient customerClient;
    private final CatalogClient catalogClient;

    public DashboardService(AuthClient authClient,
                            CustomerClient customerClient,
                            CatalogClient catalogClient) {
        this.authClient = authClient;
        this.customerClient = customerClient;
        this.catalogClient = catalogClient;
    }

    public OwnerDashboardSummary getOwnerSummary() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        List<AuthClient.UserSnapshot> users = authClient.getUsers();
        List<AuthClient.BranchSnapshot> branches = authClient.getBranches();
        long totalUsers = users.size();
        long totalEmployees = users.stream().filter(u -> isRole(u, "EMPLOYEE")).count();
        long totalManagers = users.stream().filter(u -> isRole(u, "MANAGER")).count();
        long totalCustomers = customerClient.getCustomers().size();
        long totalProducts = catalogClient.getProducts().size();
        long totalBranches = branches.size();

        return new OwnerDashboardSummary(
                timestamp,
                totalUsers,
                totalEmployees,
                totalManagers,
                totalCustomers,
                totalProducts,
                totalBranches
        );
    }

    public AdminDashboardSummary getAdminSummary() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        List<AuthClient.UserSnapshot> users = authClient.getUsers();
        List<AuthClient.BranchSnapshot> branches = authClient.getBranches();
        long totalUsers = users.size();
        long totalEmployees = users.stream().filter(u -> isRole(u, "EMPLOYEE")).count();
        long totalManagers = users.stream().filter(u -> isRole(u, "MANAGER")).count();
        long totalBranches = branches.size();
        long activeBranches = branches.stream().filter(b -> Boolean.TRUE.equals(b.getIsActive())).count();
        long totalProducts = catalogClient.getProducts().size();
        long totalCustomers = customerClient.getCustomers().size();

        return new AdminDashboardSummary(
                timestamp,
                totalUsers,
                totalEmployees,
                totalManagers,
                totalBranches,
                activeBranches,
                totalProducts,
                totalCustomers
        );
    }

    public List<RecentUserSummary> getRecentUsers() {
        return authClient.getUsers().stream()
                .sorted(Comparator.comparing(AuthClient.UserSnapshot::getCreatedAt,
                        Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(5)
                .map(this::toRecentUserSummary)
                .collect(Collectors.toList());
    }

    public List<BranchSummary> getBranchSummaries() {
        return authClient.getBranches().stream()
                .map(this::toBranchSummary)
                .collect(Collectors.toList());
    }

    private RecentUserSummary toRecentUserSummary(AuthClient.UserSnapshot user) {
        String createdAt = user.getCreatedAt() != null
                ? user.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
                : null;
        String fullName = user.getFullName() != null ? user.getFullName() : "-";
        String role = user.getRole() != null ? user.getRole() : "-";
        return new RecentUserSummary(
                user.getId(),
                user.getUsername(),
                fullName,
                role,
                createdAt
        );
    }

    private BranchSummary toBranchSummary(AuthClient.BranchSnapshot branch) {
        String ownerName = "-";
        if (branch.getOwner() != null) {
            ownerName = branch.getOwner().getFullName();
            if (ownerName == null || ownerName.isBlank()) {
                ownerName = branch.getOwner().getUsername();
            }
        }
        return new BranchSummary(
                branch.getId(),
                branch.getName(),
                ownerName,
                branch.getIsActive(),
                branch.getAddress()
        );
    }

    private boolean isRole(AuthClient.UserSnapshot user, String role) {
        if (user == null || user.getRole() == null) {
            return false;
        }
        return role.equalsIgnoreCase(user.getRole());
    }
}
