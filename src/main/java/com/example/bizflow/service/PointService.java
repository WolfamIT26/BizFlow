package com.example.bizflow.service;

import java.math.BigDecimal;

import org.springframework.stereotype.Service;

@Service
public class PointService {

    public static void addPoints(Long id, BigDecimal totalAmount, String string) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'addPoints'");
    }

<<<<<<< HEAD
    private String redisKey(Long customerId) {
        return "customer:points:" + customerId;
    }

    /**
     * 1.000 VNĐ = 1 điểm
     */
    @SuppressWarnings("null")
    public void addPoints(Long customerId, BigDecimal totalAmount, String reason) {

        System.out.println("🔥 addPoints CALLED - customerId=" + customerId + ", reason=" + reason);

        if (customerId == null || totalAmount == null) return;

        // ✅ chống cộng trùng
        if (pointHistoryRepository.existsByCustomerIdAndReason(customerId, reason)) {
            System.out.println("⚠️ Points already added, skip");
            return;
        }

        Customer customer = customerRepository
                .findByIdForUpdate(customerId)
                .orElse(null);

        if (customer == null) return;

        int earnedPoints = totalAmount
                .divide(BigDecimal.valueOf(1000), RoundingMode.DOWN)
                .intValue();

        if (earnedPoints <= 0) return;

        // ✅ cộng DB
        customer.addPoints(earnedPoints);
        customerRepository.save(customer);

        // ✅ lưu lịch sử
        PointHistory history = new PointHistory();
        history.setCustomer(customer);
        history.setPoints(earnedPoints);
        history.setReason(reason);
        pointHistoryRepository.save(history);

        // ✅ update redis SAU – không ảnh hưởng transaction
        Integer totalPoints = customer.getTotalPoints();
        if (totalPoints != null) {
            try {
                redisTemplate.opsForValue().set(
                        redisKey(customerId),
                        totalPoints,
                        1,
                        TimeUnit.DAYS
                );
            } catch (Exception ex) {
                System.out.println("⚠️ Redis unavailable, skip cache update: " + ex.getMessage());
            }
        }

        System.out.println("✅ Added " + earnedPoints + " points for customer " + customerId);
    }

    @SuppressWarnings("null")
    public Integer getTotalPoints(Long customerId) {
        String key = redisKey(customerId);

        try {
            Integer cached = redisTemplate.opsForValue().get(key);
            if (cached != null) return cached;
        } catch (Exception ex) {
            System.out.println("⚠️ Redis unavailable, skip cache read: " + ex.getMessage());
        }

        Customer customer = customerRepository.findById(customerId).orElse(null);
        if (customer == null) return 0;

        Integer totalPoints = customer.getTotalPoints();
        if (totalPoints != null) {
            try {
                redisTemplate.opsForValue().set(
                        key,
                        totalPoints,
                        1,
                        TimeUnit.DAYS
                );
            } catch (Exception ex) {
                System.out.println("⚠️ Redis unavailable, skip cache update: " + ex.getMessage());
            }
        }

        return totalPoints != null ? totalPoints : 0;
    }
=======
>>>>>>> 0e749eb7b88fec30ee558c76cbf18fee7af4255a
}
