package com.example.admin.controller;

import java.nio.charset.StandardCharsets;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("/api/dashboard")
public class AdminDashboardController {
    private final RestTemplate restTemplate;
    private final String coreBaseUrl;

    public AdminDashboardController(RestTemplate restTemplate,
                                    @Value("${core.base-url:http://backend:8080}") String coreBaseUrl) {
        this.restTemplate = restTemplate;
        this.coreBaseUrl = coreBaseUrl;
    }

    @GetMapping("/admin-summary")
    public ResponseEntity<byte[]> getAdminSummary(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        return forward("/api/dashboard/admin-summary", authHeader);
    }

    @GetMapping("/recent-users")
    public ResponseEntity<byte[]> getRecentUsers(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        return forward("/api/dashboard/recent-users", authHeader);
    }

    @GetMapping("/branches")
    public ResponseEntity<byte[]> getBranches(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        return forward("/api/dashboard/branches", authHeader);
    }

    private ResponseEntity<byte[]> forward(String path, String authHeader) {
        HttpHeaders headers = new HttpHeaders();
        if (authHeader != null && !authHeader.isBlank()) {
            headers.set(HttpHeaders.AUTHORIZATION, authHeader);
        }
        try {
            ResponseEntity<byte[]> response = restTemplate.exchange(
                    coreBaseUrl + path,
                    HttpMethod.GET,
                    new HttpEntity<>(headers),
                    byte[].class
            );
            return buildResponse(response.getStatusCode(), response.getHeaders(), response.getBody());
        } catch (RestClientResponseException ex) {
            return buildResponse(ex.getStatusCode(), ex.getResponseHeaders(), ex.getResponseBodyAsByteArray());
        } catch (ResourceAccessException ex) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                    .body(("Gateway error: " + ex.getMessage()).getBytes(StandardCharsets.UTF_8));
        }
    }

    private ResponseEntity<byte[]> buildResponse(HttpStatusCode status, HttpHeaders sourceHeaders, byte[] body) {
        ResponseEntity.BodyBuilder builder = ResponseEntity.status(status);
        if (sourceHeaders != null) {
            MediaType contentType = sourceHeaders.getContentType();
            if (contentType != null) {
                builder.contentType(contentType);
            }
        }
        return builder.body(body);
    }
}
