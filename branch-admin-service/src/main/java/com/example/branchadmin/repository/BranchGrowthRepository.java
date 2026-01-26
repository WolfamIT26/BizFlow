package com.example.branchadmin.repository;

import com.example.branchadmin.entity.BranchGrowthEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BranchGrowthRepository extends JpaRepository<BranchGrowthEntity, Long> {
    List<BranchGrowthEntity> findByBranchIdOrderByPeriodLabelDesc(Long branchId);
}
