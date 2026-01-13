package com.example.bizflow.controller;

import com.example.bizflow.dto.CreateOrderRequest;
import com.example.bizflow.dto.CreateOrderResponse;
import com.example.bizflow.dto.OrderItemRequest;
import com.example.bizflow.entity.Customer;
import com.example.bizflow.entity.CustomerTier;
import com.example.bizflow.entity.Order;
import com.example.bizflow.entity.OrderItem;
import com.example.bizflow.entity.Payment;
import com.example.bizflow.entity.Product;
import com.example.bizflow.entity.Promotion;
import com.example.bizflow.entity.BundleItem;
import com.example.bizflow.entity.PromotionTarget;
import com.example.bizflow.entity.User;
import com.example.bizflow.repository.CustomerRepository;
import com.example.bizflow.repository.OrderItemRepository;
import com.example.bizflow.repository.OrderRepository;
import com.example.bizflow.repository.PaymentRepository;
import com.example.bizflow.repository.ProductRepository;
import com.example.bizflow.repository.PromotionRepository;
import com.example.bizflow.repository.UserRepository;
import com.example.bizflow.service.OrderService;
import com.example.bizflow.service.PointService;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;


@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final PaymentRepository paymentRepository;
    private final ProductRepository productRepository;
    private final PromotionRepository promotionRepository;
    private final CustomerRepository customerRepository;
    private final UserRepository userRepository;
    private final OrderService orderService;
    private final PointService pointService;

    public OrderController(
            OrderRepository orderRepository,
            OrderItemRepository orderItemRepository,
            PaymentRepository paymentRepository,
            ProductRepository productRepository,
            PromotionRepository promotionRepository,
            CustomerRepository customerRepository,
            UserRepository userRepository,
            OrderService orderService,
            PointService pointService
    ) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.paymentRepository = paymentRepository;
        this.productRepository = productRepository;
        this.promotionRepository = promotionRepository;
        this.customerRepository = customerRepository;
        this.userRepository = userRepository;
        this.orderService = orderService;
        this.pointService = pointService;
    }

    // ================== TẠO ĐƠN + THANH TOÁN ==================
    @PostMapping
    @Transactional
    public ResponseEntity<?> createOrder(@RequestBody CreateOrderRequest request) {

        if (request.getItems() == null || request.getItems().isEmpty()) {
            return ResponseEntity.badRequest().body("Order items are required");
        }

        Long userId = request.getUserId();
        User user = null;
        if (userId != null) {
            user = userRepository.findById(userId).orElse(null);
        }

        Long customerId = request.getCustomerId();
        Customer customer = null;
        if (customerId != null) {
            customer = customerRepository.findById(customerId).orElse(null);
        }

        boolean paid = Boolean.TRUE.equals(request.getPaid());

        Order order = new Order();
        order.setUser(user);
        order.setCustomer(customer);
        order.setStatus(paid ? "PAID" : "UNPAID");
        order.setInvoiceNumber(
                orderService.generateInvoiceNumberForDate(LocalDate.now(), "SALE")
        );

        BigDecimal total = BigDecimal.ZERO;
        List<OrderItem> items = new ArrayList<>();
        List<Promotion> activePromotions = promotionRepository.findActivePromotions(LocalDateTime.now());

        for (OrderItemRequest req : request.getItems()) {

            Long productId = req.getProductId();
            if (productId == null) {
                return ResponseEntity.badRequest().body("Product is required");
            }

            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product not found"));

            int qty = req.getQuantity();
            if (qty <= 0) {
                return ResponseEntity.badRequest().body("Quantity must be > 0");
            }

            BigDecimal unitPrice = resolvePromotionalPrice(product, activePromotions);
            BigDecimal lineTotal = unitPrice.multiply(BigDecimal.valueOf(qty));

            total = total.add(lineTotal);

            OrderItem item = new OrderItem();
            item.setOrder(order);
            item.setProduct(product);
            item.setQuantity(qty);
            item.setPrice(unitPrice);
            items.add(item);
        }

        BigDecimal memberDiscount = BigDecimal.ZERO;
        int pointsUsed = 0;
        if (paid && customer != null && Boolean.TRUE.equals(request.getUsePoints())) {
            DiscountResult result = resolveMemberDiscount(customer, total);
            memberDiscount = result.discount;
            pointsUsed = result.pointsUsed;
            total = total.subtract(memberDiscount).max(BigDecimal.ZERO);
        }

        order.setTotalAmount(total);
        Order savedOrder = orderRepository.save(order);

        items.forEach(i -> i.setOrder(savedOrder));
        orderItemRepository.saveAll(items);

        if (paid) {
            Payment payment = new Payment();
            payment.setOrder(savedOrder);
            payment.setMethod(
                    request.getPaymentMethod() == null ? "CASH" : request.getPaymentMethod()
            );
            payment.setAmount(total);
            payment.setStatus("PAID");
            payment.setPaidAt(java.time.LocalDateTime.now());
            paymentRepository.save(payment);

            // ✅ CỘNG ĐIỂM KHÁCH HÀNG (KHÔNG PHỤ THUỘC PHƯƠNG THỨC)
            if (customer != null) {
                if (pointsUsed > 0) {
                    pointService.redeemPoints(customer.getId(), pointsUsed);
                }
                pointService.addPoints(
                        customer.getId(),
                        total,
                        "ORDER_" + savedOrder.getId()
                );
            }
        }

        return ResponseEntity.ok(
                new CreateOrderResponse(
                        savedOrder.getId(),
                        total,
                        items.size(),
                        paid,
                        null
                )
        );
    }

    private DiscountResult resolveMemberDiscount(Customer customer, BigDecimal total) {
        if (customer == null || total == null || total.compareTo(BigDecimal.ZERO) <= 0) {
            return new DiscountResult(BigDecimal.ZERO, 0);
        }
        int points = customer.getTotalPoints() == null ? 0 : customer.getTotalPoints();
        if (points < 100) {
            return new DiscountResult(BigDecimal.ZERO, 0);
        }

        CustomerTier tier = customer.getTier();
        if (tier == null) {
            tier = resolveTierByPoints(points);
        }
        if (tier == null) {
            return new DiscountResult(BigDecimal.ZERO, 0);
        }

        int rate = tier.discountValue;
        if (rate <= 0) {
            return new DiscountResult(BigDecimal.ZERO, 0);
        }

        int stepsByPoints = points / 100;
        int stepsByTotal = total.divide(BigDecimal.valueOf(rate), 0, RoundingMode.DOWN).intValue();
        int stepsUsed = Math.max(0, Math.min(stepsByPoints, stepsByTotal));
        if (stepsUsed <= 0) {
            return new DiscountResult(BigDecimal.ZERO, 0);
        }

        BigDecimal discount = BigDecimal.valueOf((long) stepsUsed * rate);
        int pointsUsed = stepsUsed * 100;
        return new DiscountResult(discount, pointsUsed);
    }

    private CustomerTier resolveTierByPoints(int points) {
        CustomerTier selected = null;
        for (CustomerTier tier : CustomerTier.values()) {
            if (points >= tier.monthlyLimit) {
                if (selected == null || tier.monthlyLimit > selected.monthlyLimit) {
                    selected = tier;
                }
            }
        }
        return selected;
    }

    private static class DiscountResult {
        private final BigDecimal discount;
        private final int pointsUsed;

        private DiscountResult(BigDecimal discount, int pointsUsed) {
            this.discount = discount;
            this.pointsUsed = pointsUsed;
        }
    }

    private BigDecimal resolvePromotionalPrice(Product product, List<Promotion> promotions) {
        if (product == null || product.getPrice() == null) {
            return BigDecimal.ZERO;
        }
        if (promotions == null || promotions.isEmpty()) {
            return product.getPrice();
        }

        BigDecimal basePrice = product.getPrice();
        BigDecimal bestPrice = null;

        for (Promotion promotion : promotions) {
            if (promotion == null || !appliesToProduct(promotion, product)) {
                continue;
            }
            BigDecimal candidate = calculateDiscountedPrice(basePrice, promotion);
            if (candidate == null) {
                continue;
            }
            if (bestPrice == null || candidate.compareTo(bestPrice) < 0) {
                bestPrice = candidate;
            }
        }

        return bestPrice != null ? bestPrice : basePrice;
    }

    private boolean appliesToProduct(Promotion promotion, Product product) {
        Long productId = product.getId();
        Long categoryId = product.getCategoryId();

        List<PromotionTarget> targets = promotion.getTargets();
        if (targets != null) {
            for (PromotionTarget target : targets) {
                if (target == null || target.getTargetId() == null || target.getTargetType() == null) {
                    continue;
                }
                if (target.getTargetType() == PromotionTarget.TargetType.PRODUCT
                        && productId != null
                        && productId.equals(target.getTargetId())) {
                    return true;
                }
                if (target.getTargetType() == PromotionTarget.TargetType.CATEGORY
                        && categoryId != null
                        && categoryId.equals(target.getTargetId())) {
                    return true;
                }
            }
        }

        List<BundleItem> bundleItems = promotion.getBundleItems();
        if (bundleItems != null) {
            for (BundleItem item : bundleItems) {
                if (item == null || item.getProductId() == null) {
                    continue;
                }
                if (productId != null && productId.equals(item.getProductId())) {
                    return true;
                }
            }
        }

        return false;
    }

    private BigDecimal calculateDiscountedPrice(BigDecimal basePrice, Promotion promotion) {
        if (basePrice == null || promotion == null || promotion.getDiscountType() == null) {
            return null;
        }

        BigDecimal value = promotion.getDiscountValue() == null
                ? null
                : BigDecimal.valueOf(promotion.getDiscountValue());

        return switch (promotion.getDiscountType()) {
            case PERCENT -> {
                if (value == null) {
                    yield null;
                }
                BigDecimal percent = value.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
                yield basePrice.multiply(BigDecimal.ONE.subtract(percent)).max(BigDecimal.ZERO);
            }
            case FIXED, FIXED_AMOUNT -> value == null ? null : basePrice.subtract(value).max(BigDecimal.ZERO);
            case BUNDLE -> value == null ? null : value.max(BigDecimal.ZERO);
            case FREE_GIFT -> basePrice;
        };
    }
}
