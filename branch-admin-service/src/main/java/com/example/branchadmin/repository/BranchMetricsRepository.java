package com.example.branchadmin.repository;

import com.example.branchadmin.entity.BranchMetricsEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BranchMetricsRepository extends JpaRepository<BranchMetricsEntity, Long> {
}
