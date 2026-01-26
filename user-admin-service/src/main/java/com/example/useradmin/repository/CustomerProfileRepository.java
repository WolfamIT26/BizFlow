package com.example.useradmin.repository;

import com.example.useradmin.entity.CustomerProfile;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CustomerProfileRepository extends JpaRepository<CustomerProfile, Long> {
    @Query("SELECT c FROM CustomerProfile c WHERE c.normalizedText LIKE %:keyword% ORDER BY c.name ASC")
    List<CustomerProfile> search(@Param("keyword") String keyword, Pageable pageable);
}
