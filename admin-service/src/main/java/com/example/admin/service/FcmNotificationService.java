package com.example.admin.service;

import com.example.admin.dto.AdminOrderDetail;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
public class FcmNotificationService {
    private static final Logger logger = LoggerFactory.getLogger(FcmNotificationService.class);
    private static final String FCM_URL = "https://fcm.googleapis.com/fcm/send";

    private final RestTemplate restTemplate;
    private final boolean enabled;
    private final String serverKey;
    private final String topic;

    public FcmNotificationService(RestTemplate restTemplate,
                                  @Value("${fcm.enabled:false}") boolean enabled,
                                  @Value("${fcm.server-key:}") String serverKey,
                                  @Value("${fcm.topic:}") String topic) {
        this.restTemplate = restTemplate;
        this.enabled = enabled;
        this.serverKey = serverKey;
        this.topic = topic;
    }

    public void sendOrderViewed(AdminOrderDetail detail, String viewer) {
        if (!enabled || serverKey == null || serverKey.isBlank() || topic == null || topic.isBlank()) {
            return;
        }
        if (detail == null || detail.getId() == null) {
            return;
        }

        Map<String, Object> payload = new HashMap<>();
        payload.put("to", "/topics/" + topic);

        Map<String, Object> notification = new HashMap<>();
        notification.put("title", "Order viewed");
        notification.put("body", "Order #" + detail.getId() + " viewed by admin.");
        payload.put("notification", notification);

        Map<String, Object> data = new HashMap<>();
        data.put("orderId", detail.getId());
        data.put("branchId", detail.getBranchId());
        data.put("branchName", detail.getBranchName());
        data.put("viewer", viewer);
        payload.put("data", data);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "key=" + serverKey);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(
                    FCM_URL,
                    new HttpEntity<>(payload, headers),
                    String.class
            );
            if (!response.getStatusCode().is2xxSuccessful()) {
                logger.debug("FCM send failed: {}", response.getStatusCode());
            }
        } catch (Exception ex) {
            logger.debug("FCM send failed: {}", ex.getMessage());
        }
    }
}
