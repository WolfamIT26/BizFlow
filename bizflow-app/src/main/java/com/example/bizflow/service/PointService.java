package com.example.bizflow.service;

import com.example.bizflow.entity.Customer;
import com.example.bizflow.entity.CustomerTier;
import com.example.bizflow.repository.CustomerRepository;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
public class PointService {
    private final CustomerRepository customerRepository;
    private final RedisTemplate<String, Integer> redisTemplate;
    private static final String POINTS_KEY_PREFIX = "customer:points:";

    public PointService(CustomerRepository customerRepository,
                        RedisTemplate<String, Integer> redisTemplate) {
        this.customerRepository = customerRepository;
        this.redisTemplate = redisTemplate;
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
            cachePoints(customerId, customer.getTotalPoints());
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
            cachePoints(customerId, customer.getTotalPoints());
            return redeem;
        }).orElse(0);
    }

    public int getAvailablePoints(Long customerId, Integer fallback) {
        if (customerId == null) {
            return fallback == null ? 0 : fallback;
        }
        try {
            Integer cached = redisTemplate.opsForValue().get(pointsKey(customerId));
            if (cached != null) {
                return cached;
            }
        } catch (Exception ignored) {
        }
        if (fallback != null) {
            cachePoints(customerId, fallback);
            return fallback;
        }
        return customerRepository.findById(customerId)
                .map(Customer::getTotalPoints)
                .map(points -> {
                    cachePoints(customerId, points);
                    return points == null ? 0 : points;
                })
                .orElse(0);
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

    private void cachePoints(Long customerId, Integer points) {
        if (customerId == null || points == null) {
            return;
        }
        try {
            redisTemplate.opsForValue().set(pointsKey(customerId), points);
        } catch (Exception ignored) {
        }
    }

    private String pointsKey(Long customerId) {
        return POINTS_KEY_PREFIX + customerId;
    }
}
