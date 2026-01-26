package com.example.useradmin.service;

import com.example.useradmin.dto.AdminCustomerSummary;
import com.example.useradmin.dto.AdminSearchResponse;
import com.example.useradmin.dto.AdminUserSummary;
import com.example.useradmin.entity.CustomerProfile;
import com.example.useradmin.entity.UserProfile;
import com.example.useradmin.repository.CustomerProfileRepository;
import com.example.useradmin.repository.UserProfileRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

@Service
public class UserSearchService {
    private static final Pattern DIACRITICS = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");

    private final UserProfileRepository userProfileRepository;
    private final CustomerProfileRepository customerProfileRepository;

    public UserSearchService(UserProfileRepository userProfileRepository,
                             CustomerProfileRepository customerProfileRepository) {
        this.userProfileRepository = userProfileRepository;
        this.customerProfileRepository = customerProfileRepository;
    }

    public AdminSearchResponse search(String keyword, String role, int limit) {
        String normalizedKeyword = normalize(keyword == null ? "" : keyword);
        if (normalizedKeyword.isBlank()) {
            return new AdminSearchResponse(new ArrayList<>(), new ArrayList<>(), 0, 0);
        }

        int safeLimit = Math.max(limit, 1);
        Pageable pageable = PageRequest.of(0, safeLimit);
        List<UserProfile> users = userProfileRepository.search(normalizedKeyword, normalizeRole(role), pageable);
        List<CustomerProfile> customers = customerProfileRepository.search(normalizedKeyword, pageable);

        List<AdminUserSummary> userSummaries = new ArrayList<>();
        for (UserProfile user : users) {
            userSummaries.add(new AdminUserSummary(
                    user.getId(),
                    user.getUsername(),
                    user.getFullName(),
                    user.getEmail(),
                    user.getPhoneNumber(),
                    user.getRole(),
                    user.getEnabled()
            ));
        }

        List<AdminCustomerSummary> customerSummaries = new ArrayList<>();
        for (CustomerProfile customer : customers) {
            customerSummaries.add(new AdminCustomerSummary(
                    customer.getId(),
                    customer.getName(),
                    customer.getPhone(),
                    customer.getEmail(),
                    customer.getTotalPoints(),
                    customer.getTier()
            ));
        }

        return new AdminSearchResponse(userSummaries, customerSummaries, userSummaries.size(), customerSummaries.size());
    }

    private static String normalize(String input) {
        if (input == null) {
            return "";
        }
        String lower = input.trim().toLowerCase(Locale.ROOT);
        String normalized = Normalizer.normalize(lower, Normalizer.Form.NFD);
        return DIACRITICS.matcher(normalized).replaceAll("");
    }

    private static String normalizeRole(String role) {
        if (role == null || role.isBlank()) {
            return "all";
        }
        return role;
    }
}
