package com.example.admin.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Enumeration;

@RestController
public class AdminProxyController {

    private final RestTemplate restTemplate;
    private final String coreBaseUrl;

    public AdminProxyController(RestTemplate restTemplate,
                                @Value("${core.base-url:http://localhost:8080}") String coreBaseUrl) {
        this.restTemplate = restTemplate;
        this.coreBaseUrl = coreBaseUrl;
    }

    @RequestMapping({
            "/api/users/**",
            "/api/customers/**",
            "/api/auth/**",
            "/api/reports/**"
    })
    public ResponseEntity<byte[]> proxy(HttpServletRequest request,
                                        @RequestBody(required = false) byte[] body) throws IOException {
        String targetUrl = coreBaseUrl + request.getRequestURI();
        if (request.getQueryString() != null && !request.getQueryString().isBlank()) {
            targetUrl = targetUrl + "?" + request.getQueryString();
        }

        HttpHeaders headers = new HttpHeaders();
        Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String headerName = headerNames.nextElement();
            if ("host".equalsIgnoreCase(headerName)) {
                continue;
            }
            Enumeration<String> values = request.getHeaders(headerName);
            while (values.hasMoreElements()) {
                headers.add(headerName, values.nextElement());
            }
        }

        HttpMethod method;
        try {
            method = HttpMethod.valueOf(request.getMethod());
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED).build();
        }

        byte[] payload = body;
        if (payload == null && ("POST".equalsIgnoreCase(request.getMethod()) || "PUT".equalsIgnoreCase(request.getMethod()) || "PATCH".equalsIgnoreCase(request.getMethod()))) {
            payload = StreamUtils.copyToByteArray(request.getInputStream());
        }

        HttpEntity<byte[]> entity = new HttpEntity<>(payload, headers);
        try {
            ResponseEntity<byte[]> response = restTemplate.exchange(targetUrl, method, entity, byte[].class);
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
