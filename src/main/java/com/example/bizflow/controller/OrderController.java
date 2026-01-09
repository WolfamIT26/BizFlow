package com.example.bizflow.controller;

import com.example.bizflow.dto.CreateOrderRequest;
import com.example.bizflow.dto.CreateOrderResponse;
import com.example.bizflow.dto.OrderItemRequest;
import com.example.bizflow.entity.Customer;
import com.example.bizflow.entity.Order;
import com.example.bizflow.entity.OrderItem;
import com.example.bizflow.entity.Payment;
import com.example.bizflow.entity.Product;
import com.example.bizflow.entity.User;
import com.example.bizflow.repository.CustomerRepository;
import com.example.bizflow.repository.OrderItemRepository;
import com.example.bizflow.repository.OrderRepository;
import com.example.bizflow.repository.PaymentRepository;
import com.example.bizflow.repository.ProductRepository;
import com.example.bizflow.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

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

    public OrderController(OrderRepository orderRepository,
                           OrderItemRepository orderItemRepository,
                           PaymentRepository paymentRepository,
                           ProductRepository productRepository,
                           CustomerRepository customerRepository,
                           UserRepository userRepository) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.paymentRepository = paymentRepository;
        this.productRepository = productRepository;
        this.customerRepository = customerRepository;
        this.userRepository = userRepository;
    }

    // ================== TẠO ĐƠN + THANH TOÁN NGAY ==================
    @PostMapping
@Transactional
public ResponseEntity<?> createOrder(@RequestBody CreateOrderRequest request) {

    if (request.getItems() == null || request.getItems().isEmpty()) {
        return ResponseEntity.badRequest().body("Order items are required");
    }

        User user = null;
        if (request.getUserId() != null) {
            Long userId = request.getUserId();
            user = userRepository.findById(userId).orElse(null);
        }

        Customer customer = null;
        if (request.getCustomerId() != null && request.getCustomerId() > 0) {
            Long customerId = request.getCustomerId();
            customer = customerRepository.findById(customerId).orElse(null);
        }

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

        boolean paid = Boolean.TRUE.equals(request.getPaid());
        String paymentToken = null;
        if (paid) {
            Payment payment = new Payment();
            payment.setOrder(savedOrder);
            payment.setMethod(request.getPaymentMethod() == null ? "CASH" : request.getPaymentMethod());
            payment.setAmount(total);
            payment.setStatus("PAID");
            payment.setPaidAt(java.time.LocalDateTime.now());
            paymentRepository.save(payment);
        } else if (request.getPaymentMethod() != null && "TRANSFER".equalsIgnoreCase(request.getPaymentMethod())) {
            // create pending transfer payment with a token
            Payment payment = new Payment();
            payment.setOrder(savedOrder);
            payment.setMethod("TRANSFER");
            payment.setAmount(total);
            payment.setStatus("PENDING");
            paymentToken = java.util.UUID.randomUUID().toString();
            payment.setToken(paymentToken);
            paymentRepository.save(payment);
        }

        return ResponseEntity.ok(new CreateOrderResponse(
                savedOrder.getId(),
                total,
                orderItems.size(),
                paid,
                paymentToken
        ));
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
