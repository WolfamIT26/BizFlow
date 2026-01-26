package com.example.useradmin.service;

import com.example.useradmin.dto.AdminUserStatsResponse;
import com.example.useradmin.repository.UserProfileRepository;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;

@Service
public class UserStatsService {
    private static final int DEFAULT_WINDOW_DAYS = 30;

    private final UserProfileRepository userProfileRepository;

    public UserStatsService(UserProfileRepository userProfileRepository) {
        this.userProfileRepository = userProfileRepository;
    }

    public AdminUserStatsResponse buildStats(String role, Integer windowDays) {
        int days = resolveWindowDays(windowDays);
        Instant threshold = Instant.now().minus(Duration.ofDays(days));

        long activeUsers;
        long newRegistrations;
        if (role == null || role.isBlank() || "all".equalsIgnoreCase(role)) {
            activeUsers = userProfileRepository.countByEnabledTrueAndCreatedAtAfter(threshold);
            newRegistrations = userProfileRepository.countByCreatedAtAfter(threshold);
        } else {
            activeUsers = userProfileRepository.countByRoleIgnoreCaseAndEnabledTrueAndCreatedAtAfter(role, threshold);
            newRegistrations = userProfileRepository.countByRoleIgnoreCaseAndCreatedAtAfter(role, threshold);
        }

        return new AdminUserStatsResponse(safeCast(activeUsers), safeCast(newRegistrations), days);
    }

    private int resolveWindowDays(Integer windowDays) {
        if (windowDays == null || windowDays <= 0) {
            return DEFAULT_WINDOW_DAYS;
        }
        return windowDays;
    }

    private int safeCast(long value) {
        if (value >= Integer.MAX_VALUE) {
            return Integer.MAX_VALUE;
        }
        if (value <= Integer.MIN_VALUE) {
            return Integer.MIN_VALUE;
        }
        return (int) value;
    }
}
