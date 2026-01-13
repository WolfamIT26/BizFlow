package com.example.bizflow.service;

import com.example.bizflow.repository.CustomerRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
public class PointService {
    private final CustomerRepository customerRepository;

    public PointService(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    @Transactional
    public void addPoints(Long customerId, BigDecimal totalAmount, String reference) {
        if (customerId == null || totalAmount == null) {
            return;
        }

        int points = totalAmount.intValue();
        if (points <= 0) {
            return;
        }

        customerRepository.findByIdForUpdate(customerId).ifPresent(customer -> {
            customer.addPoints(points);
            customerRepository.save(customer);
        });
    }
}
