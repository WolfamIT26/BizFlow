package com.example.useradmin.repository;

import com.example.useradmin.entity.UserProfile;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {
    @Query("SELECT u FROM UserProfile u WHERE (:role = 'all' OR LOWER(u.role) = LOWER(:role)) AND u.normalizedText LIKE %:keyword% ORDER BY u.username ASC")
    List<UserProfile> search(@Param("keyword") String keyword,
                             @Param("role") String role,
                             Pageable pageable);

    long countByEnabledTrueAndCreatedAtAfter(Instant threshold);

    long countByRoleIgnoreCaseAndEnabledTrueAndCreatedAtAfter(String role, Instant threshold);

    long countByCreatedAtAfter(Instant threshold);

    long countByRoleIgnoreCaseAndCreatedAtAfter(String role, Instant threshold);
}
