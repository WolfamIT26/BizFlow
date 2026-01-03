package com.example.bizflow.controller;

import com.example.bizflow.dto.CreateOrderRequest;
import com.example.bizflow.dto.CreateOrderResponse;
import com.example.bizflow.dto.OrderItemRequest;
import com.example.bizflow.dto.OrderResponse;
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
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/orders")
@SuppressWarnings("null")
public class OrderController {
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final PaymentRepository paymentRepository;
    private final ProductRepository productRepository;
    private final CustomerRepository customerRepository;
    private final UserRepository userRepository;
    private final OrderService orderService;

    public OrderController(OrderRepository orderRepository,
                           OrderItemRepository orderItemRepository,
                           PaymentRepository paymentRepository,
                           ProductRepository productRepository,
                           CustomerRepository customerRepository,
                           UserRepository userRepository,
                           OrderService orderService) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.paymentRepository = paymentRepository;
        this.productRepository = productRepository;
        this.customerRepository = customerRepository;
        this.userRepository = userRepository;
        this.orderService = orderService;
    }

    @GetMapping
    public ResponseEntity<List<OrderResponse>> getOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    @GetMapping("/summary")
    public ResponseEntity<List<OrderSummaryResponse>> getOrderSummaries() {
        return ResponseEntity.ok(orderService.getAllOrderSummaries());
    }

    @GetMapping("/number/{invoiceNumber}")
    public ResponseEntity<?> getOrderByInvoiceNumber(@PathVariable String invoiceNumber) {
        Optional<OrderResponse> order = orderService.getOrderByInvoiceNumber(invoiceNumber);
        return order.<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOrderById(@PathVariable Long id) {
        Optional<OrderResponse> order = orderService.getOrderDetail(id);
        return order.<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    @Transactional
    public ResponseEntity<?> createOrder(@RequestBody CreateOrderRequest request) {
        if (request == null || request.getItems() == null || request.getItems().isEmpty()) {
            return ResponseEntity.badRequest().body("Order items are required.");
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

        boolean isReturn = Boolean.TRUE.equals(request.getReturnOrder());
        boolean paid = Boolean.TRUE.equals(request.getPaid());

        Order order = new Order();
        order.setUser(user);
        order.setCustomer(customer);
        order.setReturnOrder(isReturn);
        order.setStatus(isReturn ? "RETURNED" : (paid ? "PAID" : "UNPAID"));
        order.setInvoiceNumber(orderService.generateInvoiceNumber(isReturn));

        BigDecimal total = BigDecimal.ZERO;
        List<OrderItem> orderItems = new ArrayList<>();
        for (OrderItemRequest itemRequest : request.getItems()) {
            if (itemRequest == null || itemRequest.getProductId() == null) {
                return ResponseEntity.badRequest().body("Product id is required.");
            }

            int qty = itemRequest.getQuantity() == null ? 0 : itemRequest.getQuantity();
            if (qty <= 0) {
                return ResponseEntity.badRequest().body("Quantity must be greater than 0.");
            }

            Long productId = itemRequest.getProductId();
            Product product = productRepository.findById(productId).orElse(null);
            if (product == null) {
                return ResponseEntity.badRequest().body("Product not found: " + productId);
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

        if (paid) {
            Payment payment = new Payment();
            payment.setOrder(savedOrder);
            payment.setMethod(request.getPaymentMethod() == null ? "CASH" : request.getPaymentMethod());
            payment.setAmount(total);
            paymentRepository.save(payment);
        }

        return ResponseEntity.ok(new CreateOrderResponse(
                savedOrder.getId(),
                total,
                orderItems.size(),
                paid,
                savedOrder.getInvoiceNumber()
        ));
    }
}
