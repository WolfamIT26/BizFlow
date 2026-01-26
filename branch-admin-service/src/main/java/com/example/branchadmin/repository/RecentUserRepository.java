package com.example.branchadmin.repository;

import com.example.branchadmin.entity.RecentUserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecentUserRepository extends JpaRepository<RecentUserEntity, Long> {
    List<RecentUserEntity> findTop10ByOrderByRegisteredAtDesc();
}
