package com.example.bizflow.controller;

import com.example.bizflow.entity.Customer;
import com.example.bizflow.repository.CustomerRepository;
import com.example.bizflow.service.OrderService;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@RestController
@RequestMapping("/api/customers")
public class CustomerController {
    private final CustomerRepository customerRepository;
    private final OrderService orderService;

    public CustomerController(CustomerRepository customerRepository,
                              OrderService orderService) {
        this.customerRepository = customerRepository;
        this.orderService = orderService;
    }
    
    @GetMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'OWNER', 'ADMIN')")
    public ResponseEntity<?> getAllCustomers() {
        try {
            List<Customer> customers = customerRepository.findAll();
            return ResponseEntity.ok(customers);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error fetching customers: " + e.getMessage());
        }
    }
    
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'OWNER', 'ADMIN')")
    public ResponseEntity<?> getCustomerById(@PathVariable @NonNull Long id) {
        try {
            return customerRepository.findById(id)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error fetching customer: " + e.getMessage());
        }
    }
    
    @PostMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'OWNER', 'ADMIN')")
    public ResponseEntity<?> createCustomer(@RequestBody @NonNull CustomerCreateRequest request) {
        try {
            String name = trimToNull(request.name);
            String phone = trimToNull(request.phone);
            if (name == null) {
                return ResponseEntity.badRequest().body("Name is required.");
            }
            if (phone == null) {
                return ResponseEntity.badRequest().body("Phone is required.");
            }

            Customer customer = new Customer();
            customer.setName(name);
            customer.setPhone(phone);
            customer.setEmail(trimToNull(request.email));
            customer.setAddress(trimToNull(request.address));
            customer.setCccd(trimToNull(request.cccd));
            if (trimToNull(request.dob) != null) {
                customer.setDob(LocalDate.parse(request.dob.trim()));
            }

            Customer saved = customerRepository.save(customer);
            return ResponseEntity.ok(saved);
        } catch (DateTimeParseException e) {
            return ResponseEntity.badRequest().body("Invalid dob format. Use yyyy-MM-dd.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error creating customer: " + e.getMessage());
        }
    }

    @GetMapping("/{id}/orders")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'OWNER', 'ADMIN')")
    public ResponseEntity<Object> getCustomerOrderHistory(@PathVariable @NonNull Long id) {
        return ResponseEntity.ok(orderService.getCustomerOrderHistory(id));
    }

    private static String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static class CustomerCreateRequest {
        public String name;
        public String phone;
        public String email;
        public String address;
        public String cccd;
        public String dob;
    }
}
