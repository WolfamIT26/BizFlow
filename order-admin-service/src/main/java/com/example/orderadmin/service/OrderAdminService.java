package com.example.orderadmin.service;

import com.example.orderadmin.dto.OrderDetailDTO;
import com.example.orderadmin.dto.OrderItemDTO;
import com.example.orderadmin.dto.OrderSummaryDTO;
import com.example.orderadmin.entity.OrderItemEntity;
import com.example.orderadmin.entity.OrderSummaryEntity;
import com.example.orderadmin.repository.OrderItemRepository;
import com.example.orderadmin.repository.OrderSummaryRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class OrderAdminService {
    private final OrderSummaryRepository orderSummaryRepository;
    private final OrderItemRepository orderItemRepository;

    public OrderAdminService(OrderSummaryRepository orderSummaryRepository,
                             OrderItemRepository orderItemRepository) {
        this.orderSummaryRepository = orderSummaryRepository;
        this.orderItemRepository = orderItemRepository;
    }

    public List<OrderSummaryDTO> listOrders(int limit) {
        return orderSummaryRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .limit(limit)
                .map(this::mapSummary)
                .collect(Collectors.toList());
    }

    public OrderDetailDTO getOrder(Long id) {
        Optional<OrderSummaryEntity> summary = orderSummaryRepository.findById(id);
        if (summary.isEmpty()) {
            return null;
        }
        List<OrderItemDTO> items = orderItemRepository.findByOrder_Id(id).stream()
                .map(this::mapItem)
                .collect(Collectors.toList());
        OrderSummaryEntity entity = summary.get();
        return new OrderDetailDTO(entity.getId(), entity.getUserId(), entity.getUserName(), entity.getTotalAmount(), entity.getCreatedAt(), entity.getStatus(), items);
    }

    private OrderSummaryDTO mapSummary(OrderSummaryEntity entity) {
        return new OrderSummaryDTO(entity.getId(), entity.getUserId(), entity.getUserName(), entity.getTotalAmount(), entity.getCreatedAt(), entity.getStatus());
    }

    private OrderItemDTO mapItem(OrderItemEntity entity) {
        return new OrderItemDTO(entity.getId(), entity.getProductId(), entity.getProductName(), entity.getLineTotal(), entity.getQuantity());
    }
}
