package com.example.bizflow.service;

import com.example.bizflow.entity.Customer;
import com.example.bizflow.entity.CustomerTier;
import com.example.bizflow.repository.CustomerRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

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

        int points = totalAmount.divide(BigDecimal.valueOf(1000), java.math.RoundingMode.DOWN).intValue();
        if (points <= 0) {
            return;
        }

        customerRepository.findByIdForUpdate(customerId).ifPresent(customer -> {
            customer.addPoints(points);
            customer.updateTierByPoints();
            customerRepository.save(customer);
        });
    }

    @Transactional
    public int redeemPoints(Long customerId, int points) {
        if (customerId == null || points <= 0) {
            return 0;
        }

        return customerRepository.findByIdForUpdate(customerId).map(customer -> {
            int current = customer.getTotalPoints() == null ? 0 : customer.getTotalPoints();
            int redeem = Math.min(current, points);
            if (redeem <= 0) {
                return 0;
            }
            customer.setTotalPoints(current - redeem);
            Integer monthly = customer.getMonthlyPoints() == null ? 0 : customer.getMonthlyPoints();
            customer.setMonthlyPoints(Math.max(0, monthly - redeem));
            customer.updateTierByPoints();
            customerRepository.save(customer);
            return redeem;
        }).orElse(0);
    }

    @Transactional
    public int syncCustomerTiers() {
        List<Customer> customers = customerRepository.findAll();
        if (customers.isEmpty()) {
            return 0;
        }

        List<Customer> changed = new ArrayList<>();
        for (Customer customer : customers) {
            CustomerTier before = customer.getTier();
            customer.updateTierByPoints();
            if (before != customer.getTier()) {
                changed.add(customer);
            }
        }

        if (!changed.isEmpty()) {
            customerRepository.saveAll(changed);
        }
        return changed.size();
    }
}
