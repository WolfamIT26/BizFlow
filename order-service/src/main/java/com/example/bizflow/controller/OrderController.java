package com.example.bizflow.controller;

import com.example.bizflow.dto.CreateOrderRequest;
import com.example.bizflow.dto.CreateOrderResponse;
import com.example.bizflow.dto.OrderItemRequest;
import com.example.bizflow.dto.OrderItemResponse;
import com.example.bizflow.dto.OrderResponse;
import com.example.bizflow.dto.OrderSummaryResponse;
import com.example.bizflow.dto.PayOrderRequest;
// TODO: Replace with DTOs or RestTemplate calls
// import com.example.bizflow.entity.Customer;
// import com.example.bizflow.entity.CustomerTier;
import com.example.bizflow.entity.Order;
import com.example.bizflow.entity.OrderItem;
import com.example.bizflow.entity.Payment;
// import com.example.bizflow.entity.Product;
// import com.example.promotion.entity.Promotion;
// import com.example.promotion.entity.BundleItem;
// import com.example.promotion.entity.PromotionTarget;
// import com.example.bizflow.entity.User;
// import com.example.bizflow.repository.CustomerRepository;
import com.example.bizflow.repository.OrderItemRepository;
import com.example.bizflow.repository.OrderRepository;
import com.example.bizflow.repository.PaymentRepository;
// import com.example.bizflow.repository.ProductRepository;
// import com.example.promotion.repository.PromotionRepository;
// import com.example.bizflow.repository.UserRepository;
import com.example.bizflow.dto.OrderMessage;
import com.example.bizflow.service.OrderService;
import com.example.bizflow.service.InventoryService;
import com.example.bizflow.service.PointService;
import com.example.bizflow.service.OrderMessageProducer;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;


@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final PaymentRepository paymentRepository;
    // TODO: Call via RestTemplate/Feign
    // private final ProductRepository productRepository;
    // private final PromotionRepository promotionRepository;
    // private final CustomerRepository customerRepository;
    // private final UserRepository userRepository;
    private final OrderService orderService;
    private final PointService pointService;
    private final InventoryService inventoryService;
    private final OrderMessageProducer orderMessageProducer;

    public OrderController(
            OrderRepository orderRepository,
            OrderItemRepository orderItemRepository,
            PaymentRepository paymentRepository,
            // ProductRepository productRepository,
            // PromotionRepository promotionRepository,
            // CustomerRepository customerRepository,
            // UserRepository userRepository,
            OrderService orderService,
            PointService pointService,
            InventoryService inventoryService,
            OrderMessageProducer orderMessageProducer
    ) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.paymentRepository = paymentRepository;
        // this.productRepository = productRepository;
        // this.promotionRepository = promotionRepository;
        // this.customerRepository = customerRepository;
        // this.userRepository = userRepository;
        this.orderService = orderService;
        this.pointService = pointService;
        this.inventoryService = inventoryService;
        this.orderMessageProducer = orderMessageProducer;
    }

    @PostMapping("/{id}/pay")
    @Transactional
    public ResponseEntity<?> payOrder(@PathVariable("id") Long orderId,
                                      @RequestBody(required = false) PayOrderRequest request) {
        if (orderId == null) {
            return ResponseEntity.badRequest().body("Order id is required");
        }

        Order order = orderRepository.findByIdWithDetails(orderId).orElse(null);
        if (order == null) {
            return ResponseEntity.notFound().build();
        }

        if ("PAID".equalsIgnoreCase(order.getStatus())) {
            return ResponseEntity.ok("Order already paid");
        }

        order.setStatus("PAID");
        orderRepository.save(order);

        inventoryService.applySale(order, order.getItems(),
                order.getUser() == null ? null : order.getUser().getId());

        Payment payment = new Payment();
        payment.setOrder(order);
        payment.setMethod(request == null || request.getMethod() == null ? "TRANSFER" : request.getMethod());
        payment.setAmount(order.getTotalAmount());
        payment.setStatus("PAID");
        payment.setPaidAt(java.time.LocalDateTime.now());
        if (request != null && request.getToken() != null && !request.getToken().isBlank()) {
            payment.setToken(request.getToken().trim());
        }
        paymentRepository.save(payment);

        if (order.getCustomer() != null) {
            pointService.addPoints(
                    order.getCustomer().getId(),
                    order.getTotalAmount(),
                    "ORDER_" + order.getId()
            );
        }

        return ResponseEntity.ok("Payment confirmed");
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
                orderService.generateInvoiceNumberForDate(LocalDate.now())
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
            int currentStock = inventoryService.getAvailableStock(product.getId());
            if (paid && currentStock < qty) {
                return ResponseEntity.badRequest().body("Insufficient stock for product: " + product.getName());
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
            inventoryService.applySale(savedOrder, items, userId);

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

        // ==================== GỬI MESSAGE QUA RABBITMQ ====================
        try {
            OrderMessage orderMessage = new OrderMessage(
                savedOrder.getId(),
                savedOrder.getInvoiceNumber(),
                customer != null ? customer.getId() : null,
                customer != null ? customer.getName() : "Khách lẻ",
                customer != null ? customer.getPhone() : "-",
                total,
                items.size(),
                user != null ? user.getUsername() : "system",
                LocalDateTime.now(),
                // TODO: Replace with RestTemplate call to product-service
                items.stream()
                    .map(item -> new OrderMessage.OrderItemMessage(
                        item.getProductId(), // Changed from getProduct().getId()
                        "", // TODO: Fetch product name from product-service
                        item.getQuantity(),
                        item.getPrice()
                    ))
                    .collect(Collectors.toList())
            );
            
            orderMessageProducer.sendOrderCreatedMessage(orderMessage);
        } catch (Exception e) {
            // Log lỗi nhưng không fail order creation
            System.err.println("Failed to send RabbitMQ message: " + e.getMessage());
        }

        return ResponseEntity.ok(
                new CreateOrderResponse(
                        savedOrder.getId(),
                        total,
                        items.size(),
                        paid,
                        null,
                        savedOrder.getInvoiceNumber()
                )
        );
    }

    @GetMapping("/summary")
    public ResponseEntity<List<OrderSummaryResponse>> getOrderSummary() {
        List<Order> orders = orderRepository.findAllWithDetails();
        List<OrderSummaryResponse> result = orders.stream()
                .map(this::toSummaryResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/returns/search")
    public ResponseEntity<List<OrderSummaryResponse>> searchReturnOrders(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String fromDate,
            @RequestParam(required = false) String toDate
    ) {
        String trimmedKeyword = keyword == null ? null : keyword.trim();
        if (trimmedKeyword != null && trimmedKeyword.isBlank()) {
            trimmedKeyword = null;
        }

        LocalDateTime from = null;
        LocalDateTime to = null;
        if (fromDate != null && !fromDate.isBlank()) {
            from = LocalDate.parse(fromDate.trim()).atStartOfDay();
        }
        if (toDate != null && !toDate.isBlank()) {
            to = LocalDate.parse(toDate.trim()).atTime(LocalTime.MAX);
        }

        List<Order> orders = orderRepository.searchOrders(trimmedKeyword, from, to);
        List<OrderSummaryResponse> result = orders.stream()
                .filter(order -> "PAID".equalsIgnoreCase(order.getStatus()))
                .filter(order -> !Boolean.TRUE.equals(order.getReturnOrder()))
                .map(this::toSummaryResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderResponse> getOrderById(@PathVariable Long id) {
        return orderRepository.findByIdWithDetails(id)
                .map(order -> ResponseEntity.ok(toOrderResponse(order)))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    private DiscountResult resolveMemberDiscount(Customer customer, BigDecimal total) {
        if (customer == null || total == null || total.compareTo(BigDecimal.ZERO) <= 0) {
            return new DiscountResult(BigDecimal.ZERO, 0);
        }
        int points = pointService.getAvailablePoints(customer.getId(), customer.getTotalPoints());
        if (points < 100) {
            return new DiscountResult(BigDecimal.ZERO, 0);
        }

        CustomerTier tier = CustomerTier.resolveTierByPoints(points);

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

    private static class DiscountResult {
        private final BigDecimal discount;
        private final int pointsUsed;

        private DiscountResult(BigDecimal discount, int pointsUsed) {
            this.discount = discount;
            this.pointsUsed = pointsUsed;
        }
    }

    private OrderSummaryResponse toSummaryResponse(Order order) {
        String userName = resolveUserName(order.getUser());
        String customerName = order.getCustomer() == null ? null : order.getCustomer().getName();
        String customerPhone = order.getCustomer() == null ? null : order.getCustomer().getPhone();
        int itemCount = order.getItems() == null
                ? 0
                : order.getItems().stream()
                    .mapToInt(item -> item.getQuantity() == null ? 0 : item.getQuantity())
                    .sum();

        return new OrderSummaryResponse(
                order.getId(),
                order.getUser() == null ? null : order.getUser().getId(),
                userName,
                order.getCustomer() == null ? null : order.getCustomer().getId(),
                customerName,
                customerPhone,
                order.getTotalAmount(),
                order.getCreatedAt(),
                itemCount,
                order.getInvoiceNumber(),
                order.getStatus(),
                userName,
                userName,
                order.getNote()
        );
    }

    private OrderResponse toOrderResponse(Order order) {
        String userName = resolveUserName(order.getUser());
        String customerName = order.getCustomer() == null ? null : order.getCustomer().getName();
        String customerPhone = order.getCustomer() == null ? null : order.getCustomer().getPhone();
        List<OrderItemResponse> items = order.getItems() == null
                ? new ArrayList<>()
                : order.getItems().stream()
                    .map(this::toOrderItemResponse)
                    .collect(Collectors.toList());

        return new OrderResponse(
                order.getId(),
                order.getUser() == null ? null : order.getUser().getId(),
                userName,
                order.getCustomer() == null ? null : order.getCustomer().getId(),
                customerName,
                customerPhone,
                order.getTotalAmount(),
                order.getCreatedAt(),
                order.getInvoiceNumber(),
                order.getStatus(),
                userName,
                userName,
                items,
                order.getNote()
        );
    }

    private OrderItemResponse toOrderItemResponse(OrderItem item) {
        BigDecimal lineTotal = item.getPrice() == null || item.getQuantity() == null
                ? BigDecimal.ZERO
                : item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));

        return new OrderItemResponse(
                item.getId(),
                item.getProductId(), // Changed from getProduct().getId()
                null, // TODO: Fetch from product-service
                item.getQuantity(),
                item.getPrice(),
                lineTotal,
                null, // TODO: product code from product-service
                null, // TODO: product barcode from product-service
                null, // TODO: product unit from product-service
                null,
                null,
                null
        );
    }

    // TODO: Replace with RestTemplate call to user-service
    // private String resolveUserName(User user) {
    //     if (user == null) return null;
    //     if (user.getFullName() != null && !user.getFullName().isBlank()) {
    //         return user.getFullName();
    //     }
    //     return user.getUsername();
    // }

    // TODO: Replace with RestTemplate call to product-service and promotion-service
    // private BigDecimal resolvePromotionalPrice(Product product, List<Promotion> promotions) {
    //     if (product == null || product.getPrice() == null) {
    //         return BigDecimal.ZERO;
    //     }
    //     if (promotions == null || promotions.isEmpty()) {
    //         return product.getPrice();
    //     }
    //
    //     BigDecimal basePrice = product.getPrice();
    //     BigDecimal bestPrice = null;
    //
    //     for (Promotion promotion : promotions) {
    //         if (promotion == null || !appliesToProduct(promotion, product)) {
    //             continue;
    //         }
    //         BigDecimal candidate = calculateDiscountedPrice(basePrice, promotion);
    //         if (candidate == null) {
    //             continue;
    //         }
    //         if (bestPrice == null || candidate.compareTo(bestPrice) < 0) {
    //             bestPrice = candidate;
    //         }
    //     }
    //
    //     return bestPrice != null ? bestPrice : basePrice;
    // }

    // TODO: Replace with RestTemplate call to promotion-service
    // private boolean appliesToProduct(Promotion promotion, Product product) {
    //     Long productId = product.getId();
    //     Long categoryId = product.getCategoryId();
    //
    //     List<PromotionTarget> targets = promotion.getTargets();
    //     if (targets != null) {
    //         for (PromotionTarget target : targets) {
    //             if (target == null || target.getTargetId() == null || target.getTargetType() == null) {
    //                 continue;
    //             }
    //             if (target.getTargetType() == PromotionTarget.TargetType.PRODUCT
    //                     && productId != null
    //                     && productId.equals(target.getTargetId())) {
    //                 return true;
    //             }
    //             if (target.getTargetType() == PromotionTarget.TargetType.CATEGORY
    //                     && categoryId != null
    //                     && categoryId.equals(target.getTargetId())) {
    //                 return true;
    //             }
    //         }
    //     }
    //
    //     List<BundleItem> bundleItems = promotion.getBundleItems();
    //     if (bundleItems != null) {
    //         for (BundleItem item : bundleItems) {
    //             if (item == null || item.getProductId() == null) {
    //                 continue;
    //             }
    //             if (productId != null && productId.equals(item.getProductId())) {
    //                 return true;
    //             }
    //         }
    //     }
    //
    //     return false;
    // }

    // TODO: Replace with RestTemplate call to promotion-service
    // private BigDecimal calculateDiscountedPrice(BigDecimal basePrice, Promotion promotion) {
    //     if (basePrice == null || promotion == null || promotion.getDiscountType() == null) {
    //         return null;
    //     }
    //
    //     BigDecimal value = promotion.getDiscountValue() == null
    //             ? null
    //             : BigDecimal.valueOf(promotion.getDiscountValue());
    //
    //     return switch (promotion.getDiscountType()) {
    //         case PERCENT -> {
    //             if (value == null) {
    //                 yield null;
    //             }
    //             BigDecimal percent = value.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
    //             yield basePrice.multiply(BigDecimal.ONE.subtract(percent)).max(BigDecimal.ZERO);
    //         }
    //         case FIXED, FIXED_AMOUNT -> value == null ? null : basePrice.subtract(value).max(BigDecimal.ZERO);
    //         case BUNDLE -> value == null ? null : value.max(BigDecimal.ZERO);
    //         case FREE_GIFT -> basePrice;
    //     };
    // }
}
