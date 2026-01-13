/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package com.example.bizflow.service;

import com.example.bizflow.entity.Order;
import com.example.bizflow.repository.OrderRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Service
public class OrderService {
    private static final DateTimeFormatter INVOICE_DATE_FORMAT = DateTimeFormatter.BASIC_ISO_DATE;
    private static final String DEFAULT_TYPE = "INV";

    private final OrderRepository orderRepository;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    public String generateInvoiceNumberForDate(LocalDate date, String type) {
        String normalizedType = (type == null || type.isBlank()) ? DEFAULT_TYPE : type.trim().toUpperCase();
        String prefix = normalizedType + "-" + date.format(INVOICE_DATE_FORMAT) + "-";

        Optional<Order> latest = orderRepository.findTopByInvoiceNumberStartingWithOrderByInvoiceNumberDesc(prefix);
        int nextSequence = 1;
        if (latest.isPresent()) {
            String invoiceNumber = latest.get().getInvoiceNumber();
            if (invoiceNumber != null && invoiceNumber.startsWith(prefix)) {
                String suffix = invoiceNumber.substring(prefix.length());
                try {
                    nextSequence = Integer.parseInt(suffix) + 1;
                } catch (NumberFormatException ignored) {
                    nextSequence = 1;
                }
            }
        }

        return prefix + String.format("%04d", nextSequence);
    }

    public Object getCustomerOrderHistory(Long id) {
        if (id == null) {
            return Collections.emptyList();
        }

        List<Order> orders = orderRepository.findByCustomerIdOrderByCreatedAtDesc(id);
        return orders == null ? Collections.emptyList() : orders;
    }
}
