package com.example.admin.service;

import com.example.admin.dto.AdminOrderDetail;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Service
public class AdminOrderEventPublisher {
    private static final Logger logger = LoggerFactory.getLogger(AdminOrderEventPublisher.class);

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;
    private final FcmNotificationService fcmNotificationService;
    private final String kafkaTopic;

    public AdminOrderEventPublisher(ObjectProvider<KafkaTemplate<String, String>> kafkaTemplateProvider,
                                    ObjectMapper objectMapper,
                                    FcmNotificationService fcmNotificationService,
                                    @Value("${kafka.topic.order-views:admin.order.viewed}") String kafkaTopic) {
        this.kafkaTemplate = kafkaTemplateProvider.getIfAvailable();
        this.objectMapper = objectMapper;
        this.fcmNotificationService = fcmNotificationService;
        this.kafkaTopic = kafkaTopic;
    }

    public void publishOrderViewed(AdminOrderDetail orderDetail, String viewer) {
        if (orderDetail == null) {
            return;
        }

        Map<String, Object> payload = new HashMap<>();
        payload.put("event", "ORDER_VIEWED");
        payload.put("orderId", orderDetail.getId());
        payload.put("branchId", orderDetail.getBranchId());
        payload.put("branchName", orderDetail.getBranchName());
        payload.put("viewer", viewer);
        payload.put("createdAt", OffsetDateTime.now().toString());

        CompletableFuture.runAsync(() -> {
            try {
                String json = objectMapper.writeValueAsString(payload);
                if (kafkaTemplate != null) {
                    kafkaTemplate.send(kafkaTopic, String.valueOf(orderDetail.getId()), json);
                }
            } catch (Exception ex) {
                logger.debug("Kafka publish failed: {}", ex.getMessage());
            }
            try {
                fcmNotificationService.sendOrderViewed(orderDetail, viewer);
            } catch (Exception ex) {
                logger.debug("FCM send failed: {}", ex.getMessage());
            }
        });
    }
}
