package com.example.bizflow.controller;

import com.example.bizflow.dto.CreateOrderRequest;
import com.example.bizflow.dto.CreateOrderResponse;
import com.example.bizflow.dto.OrderItemRequest;
import com.example.bizflow.dto.OrderSummaryResponse;
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
import com.example.bizflow.service.OrderService;
import com.example.bizflow.service.PointService;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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
    private final OrderService orderService;

    public OrderController(OrderRepository orderRepository,
                           OrderItemRepository orderItemRepository,
                           PaymentRepository paymentRepository,
                           ProductRepository productRepository,
                           CustomerRepository customerRepository,
                           UserRepository userRepository,
                           PointService pointService,
                           OrderService orderService) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.paymentRepository = paymentRepository;
        this.productRepository = productRepository;
        this.customerRepository = customerRepository;
        this.userRepository = userRepository;
        this.pointService = pointService;
        this.orderService = orderService;
    }

    // ================== GET ENDPOINTS ==================
    @GetMapping("/summary")
    public ResponseEntity<List<OrderSummaryResponse>> getOrderSummaries() {
        return ResponseEntity.ok(orderService.getAllOrderSummaries());
    }

    @GetMapping("/returns/search")
    public ResponseEntity<List<OrderSummaryResponse>> searchPaidOrders(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String fromDate,
            @RequestParam(required = false) String toDate) {
        java.time.LocalDateTime from = null;
        java.time.LocalDateTime to = null;
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            from = java.time.LocalDate.parse(fromDate.trim()).atStartOfDay();
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            to = java.time.LocalDate.parse(toDate.trim()).atTime(23, 59, 59);
        }
        return ResponseEntity.ok(orderService.searchPaidOrdersByKeyword(keyword, from, to));
    }

    @GetMapping("/number/{invoiceNumber}")
    public ResponseEntity<?> getOrderByInvoiceNumber(@PathVariable String invoiceNumber) {
        return orderService.getOrderByInvoiceNumber(invoiceNumber)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOrderDetail(@PathVariable Long id) {
        return orderService.getOrderDetail(id)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // ================== TẠO ĐƠN + THANH TOÁN NGAY ==================
    @PostMapping
    @Transactional
    @SuppressWarnings("null")
    public ResponseEntity<?> createOrder(@RequestBody CreateOrderRequest request) {
        if (request.getItems() == null || request.getItems().isEmpty()) {
            return ResponseEntity.badRequest().body("Order items are required");
        }

        User user = null;
        if (request.getUserId() != null) {
            user = userRepository.findById(request.getUserId()).orElse(null);
        }

        Customer customer = null;
        if (request.getCustomerId() != null && request.getCustomerId() > 0) {
            customer = customerRepository.findById(request.getCustomerId()).orElse(null);
        }

        String orderType = request.getOrderType();
        boolean isReturn = Boolean.TRUE.equals(request.getReturnOrder())
                || "RETURN".equalsIgnoreCase(orderType);
        boolean isExchange = "EXCHANGE".equalsIgnoreCase(orderType);
        if (isReturn && orderType == null) {
            orderType = "RETURN";
        }
        if (isExchange && orderType == null) {
            orderType = "EXCHANGE";
        }
        boolean paid = Boolean.TRUE.equals(request.getPaid());

        Order order = new Order();
        order.setUser(user);
        order.setCustomer(customer);
        order.setReturnOrder(isReturn);
        order.setOrderType(orderType);
        order.setStatus(isReturn ? "RETURNED" : (paid ? "PAID" : "UNPAID"));
        order.setInvoiceNumber(orderService.generateInvoiceNumberForDate(LocalDate.now(), orderType, user));
        if (request.getOriginalOrderId() != null) {
            orderRepository.findById(request.getOriginalOrderId()).ifPresent(order::setParentOrder);
        }
        if (isReturn) {
            order.setRefundMethod(request.getRefundMethod());
            order.setReturnReason(request.getReturnReason());
            order.setReturnNote(request.getReturnNote());
        }
        order.setNote(request.getReturnNote());

        BigDecimal total = BigDecimal.ZERO;
        List<OrderItem> orderItems = new ArrayList<>();
        for (OrderItemRequest itemRequest : request.getItems()) {
            if (itemRequest == null || itemRequest.getProductId() == null) {
                return ResponseEntity.badRequest().body("Product id is required.");
            }

            int qty = itemRequest.getQuantity() == null ? 0 : itemRequest.getQuantity();
            if (!isExchange && qty <= 0) {
                return ResponseEntity.badRequest().body("Quantity must be greater than 0.");
            }
            if (isExchange && qty == 0) {
                return ResponseEntity.badRequest().body("Quantity must not be 0.");
            }

            Product product = productRepository.findById(itemRequest.getProductId()).orElse(null);
            if (product == null) {
                return ResponseEntity.badRequest().body("Product not found: " + itemRequest.getProductId());
            }

            BigDecimal price = product.getPrice() == null ? BigDecimal.ZERO : product.getPrice();
            BigDecimal lineTotal = price.multiply(BigDecimal.valueOf(qty));
            total = total.add(lineTotal);

            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setProduct(product);
            orderItem.setQuantity(qty);
            orderItem.setPrice(price);
            orderItems.add(orderItem);
        }

        order.setTotalAmount(total);
        Order savedOrder = orderRepository.save(order);
        orderItemRepository.saveAll(orderItems);

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
                paymentToken,
                savedOrder.getInvoiceNumber()
        ));
    }

    // ================== THANH TOÁN SAU ==================
    @PostMapping("/{orderId}/pay")
    @Transactional
    @SuppressWarnings("null")
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
