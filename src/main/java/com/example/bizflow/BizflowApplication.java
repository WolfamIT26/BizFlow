/*
 * File: BizflowApplication.java
 * Mô tả: File main của ứng dụng Spring Boot
 * Chức năng: Khởi động ứng dụng Spring Boot, quét các component, service, repository, controller
 */

package com.example.bizflow;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BizflowApplication {
    public static void main(String[] args) {
        SpringApplication.run(BizflowApplication.class, args);
    }
}
