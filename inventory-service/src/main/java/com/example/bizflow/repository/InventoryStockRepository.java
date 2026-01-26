package com.example.bizflow.repository;

import com.example.bizflow.entity.InventoryStock;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InventoryStockRepository extends JpaRepository<InventoryStock, Long> {
    Optional<InventoryStock> findByProductId(Long productId);
    List<InventoryStock> findByProductIdIn(List<Long> productIds);
}
