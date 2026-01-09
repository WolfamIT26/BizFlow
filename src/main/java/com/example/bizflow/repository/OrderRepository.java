package com.example.bizflow.repository;

import com.example.bizflow.entity.Order;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {
    @Query("SELECT DISTINCT o FROM Order o LEFT JOIN FETCH o.items LEFT JOIN FETCH o.user LEFT JOIN FETCH o.customer ORDER BY o.createdAt DESC")
    List<Order> findAllWithDetails();

    @Query("SELECT DISTINCT o FROM Order o LEFT JOIN FETCH o.items LEFT JOIN FETCH o.user LEFT JOIN FETCH o.customer ORDER BY o.createdAt DESC")
    List<Order> findAllByOrderByCreatedAtDesc();

    @Query("SELECT o FROM Order o LEFT JOIN FETCH o.items LEFT JOIN FETCH o.user LEFT JOIN FETCH o.customer WHERE o.id = :id")
    Optional<Order> findByIdWithDetails(@Param("id") Long id);

    @EntityGraph(attributePaths = {"items", "items.product", "user", "customer"})
    List<Order> findByCustomerIdOrderByCreatedAtDesc(Long customerId);

    Optional<Order> findTopByInvoiceNumberStartingWithOrderByInvoiceNumberDesc(String prefix);

    @EntityGraph(attributePaths = {"items", "items.product", "user", "customer"})
    Optional<Order> findByInvoiceNumber(String invoiceNumber);
}
