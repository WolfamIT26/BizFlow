package com.example.bizflow.repository;

import com.example.bizflow.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    java.util.List<Product> findByCategoryId(Long categoryId);
    java.util.Optional<Product> findByCode(String code);
    java.util.List<Product> findByStatus(String status);

    @Query("""
        SELECT p FROM Product p
        WHERE (:status IS NULL OR p.status = :status)
          AND (
            LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%'))
            OR LOWER(p.code) LIKE LOWER(CONCAT('%', :q, '%'))
            OR LOWER(p.legacyName) LIKE LOWER(CONCAT('%', :q, '%'))
            OR LOWER(p.legacyCode) LIKE LOWER(CONCAT('%', :q, '%'))
            OR LOWER(p.barcode) LIKE LOWER(CONCAT('%', :q, '%'))
          )
        """)
    java.util.List<Product> searchByStatusAndQuery(@Param("status") String status, @Param("q") String q);
}
