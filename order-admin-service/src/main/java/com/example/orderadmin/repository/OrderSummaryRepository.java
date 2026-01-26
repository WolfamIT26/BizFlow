package com.example.orderadmin.repository;

import com.example.orderadmin.entity.OrderSummaryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OrderSummaryRepository extends JpaRepository<OrderSummaryEntity, Long> {
}
