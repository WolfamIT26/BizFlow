package com.example.bizflow.controller;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import com.example.bizflow.dto.CreateOrderRequest;
import com.example.bizflow.dto.CreateOrderResponse;
import com.example.bizflow.dto.OrderItemRequest;
import com.example.bizflow.entity.*;
import com.example.bizflow.repository.*;
import com.example.bizflow.service.PointService;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final PaymentRepository paymentRepository;
    private final ProductRepository productRepository;
    private final CustomerRepository customerRepository;
    private final UserRepository userRepository;
    private final PointService pointService;

    public OrderController(OrderRepository orderRepository,
                           OrderItemRepository orderItemRepository,
                           PaymentRepository paymentRepository,
                           ProductRepository productRepository,
                           CustomerRepository customerRepository,
                           UserRepository userRepository,
                           PointService pointService) {

        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.paymentRepository = paymentRepository;
        this.productRepository = productRepository;
        this.customerRepository = customerRepository;
        this.userRepository = userRepository;
        this.pointService = pointService;
    }

    // ================== TẠO ĐƠN + THANH TOÁN NGAY ==================
    @PostMapping
@Transactional
public ResponseEntity<?> createOrder(@RequestBody CreateOrderRequest request) {

    if (request.getItems() == null || request.getItems().isEmpty()) {
        return ResponseEntity.badRequest().body("Order items are required");
    }

    User user = request.getUserId() == null ? null :
            userRepository.findById(request.getUserId()).orElse(null);

    Customer customer = request.getCustomerId() == null ? null :
            customerRepository.findById(request.getCustomerId()).orElse(null);

    Order order = new Order();
    order.setUser(user);
    order.setCustomer(customer);

    BigDecimal total = BigDecimal.ZERO;
    List<OrderItem> items = new ArrayList<>();

    for (OrderItemRequest req : request.getItems()) {
        Product product = productRepository.findById(req.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found"));

        BigDecimal lineTotal = product.getPrice()
                .multiply(BigDecimal.valueOf(req.getQuantity()));

        total = total.add(lineTotal);

        OrderItem item = new OrderItem();
        item.setOrder(order);
        item.setProduct(product);
        item.setQuantity(req.getQuantity());
        item.setPrice(product.getPrice());
        items.add(item);
    }

    order.setTotalAmount(total);
    Order savedOrder = orderRepository.save(order);

    for (OrderItem item : items) {
        item.setOrder(savedOrder);
    }
    orderItemRepository.saveAll(items);

    // ===== LUÔN TẠO PAYMENT NẾU ĐƠN ĐƯỢC THANH TOÁN =====
    if (request.getPaymentMethod() != null) {

        Payment payment = new Payment();
        payment.setOrder(savedOrder);
        payment.setMethod(request.getPaymentMethod()); // CASH / TRANSFER
        payment.setAmount(total);
        payment.setStatus("PAID");
        payment.setPaidAt(java.time.LocalDateTime.now());
        paymentRepository.save(payment);

        // 🔥 LUÔN CỘNG ĐIỂM KHI PAYMENT = PAID
        if (customer != null) {
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
                    true,
                    null
            )
    );
}

    // ================== THANH TOÁN SAU ==================
    @PostMapping("/{orderId}/pay")
    @Transactional
    public ResponseEntity<?> payOrder(@PathVariable Long orderId,
                                      @RequestBody Map<String, String> body) {

        Order order = orderRepository.findById(orderId).orElse(null);
        if (order == null) {
            return ResponseEntity.notFound().build();
        }

        Payment payment = new Payment();
        payment.setOrder(order);
        payment.setMethod(body.getOrDefault("method", "CASH"));
        payment.setAmount(order.getTotalAmount());
        payment.setStatus("PAID");
        payment.setPaidAt(java.time.LocalDateTime.now());
        paymentRepository.save(payment);

        // ✅ CỘNG ĐIỂM – KHÔNG TRÙNG
        if (order.getCustomer() != null) {
            pointService.addPoints(
                    order.getCustomer().getId(),
                    order.getTotalAmount(),
                    "ORDER_" + order.getId()
            );
        }

        return ResponseEntity.ok("Payment recorded & points added");
    }
}
