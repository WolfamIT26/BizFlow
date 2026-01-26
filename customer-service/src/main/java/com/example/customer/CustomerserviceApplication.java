package com.example.customer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = {"com.example.customer", "com.example.bizflow"})
public class CustomerserviceApplication {
    public static void main(String[] args) {
        SpringApplication.run(CustomerserviceApplication.class, args);
    }
}
