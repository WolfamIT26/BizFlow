package com.example.bizflow;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
// @EnableCaching  // Tạm disable để test RabbitMQ
public class BizflowApplication {

    public static void main(String[] args) {
        SpringApplication.run(BizflowApplication.class, args);
    }
}
